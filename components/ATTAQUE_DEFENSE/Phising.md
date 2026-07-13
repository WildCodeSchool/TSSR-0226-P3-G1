# Test d'attaque Phishing (GoPhish) et défense anti-phishing (Rspamd)

## Contexte

| Élément | Valeur |
| :-- | :-- |
| Machine attaquante | Kali Linux — `172.16.0.5` |
| Machine cible (victime) | Poste utilisateur du domaine — `rmartinez@billu.lan` |
| Serveur mail cible | `mail.billu.lan` — Postfix |
| Domaine | `billu.lan` (Windows Server pour le DNS) |
| Outil d'attaque | GoPhish v0.12.1 |
| Outil de défense | Rspamd 3.12.1 + règle Lua personnalisée |

---

## 1. Paramétrage — Attaque Phishing avec GoPhish

### Installation et configuration de l'attaquant

```bash
wget https://github.com/gophish/gophish/releases/download/v0.12.1/gophish-v0.12.1-linux-64bit.zip
unzip gophish-v0.12.1-linux-64bit.zip
cd gophish
sudo ./gophish
```

**Sending Profile** configuré avec authentification SMTP sur le serveur mail interne :

| Paramètre | Valeur |
| :-- | :-- |
| SMTP From | `postmaster@billu.lan` |
| Host | `mail.billu.lan:587` |
| Username / Password | Compte `postmaster` authentifié |
| Ignore Certificate Errors | Coché (certificat auto-signé) |

**Landing Page** : clone de l'interface webmail interne (`mail.billu.lan/mail/`), capture des identifiants activée.

![landing_page](/components/ATTAQUE_DEFENSE/Ressources/Landing_page.png)

**Email Template** : mail usurpant le support informatique, prétexte d'expiration de mot de passe sous 24h, avec bouton d'action pointant vers la landing page (`{{.URL}}`).

![email_template](/components/ATTAQUE_DEFENSE/Ressources/Email_template.png)

**Cible** : groupe `Billu.lan` contenant `rmartinez@billu.lan`.

![sending_profile](/components/ATTAQUE_DEFENSE/Ressources/config_gophish.png)

---

## 2. Test — Lancement de la campagne

```
URL de campagne : http://172.16.0.5
Sending Profile : serveur mail interne
Landing Page    : MailPage
Groupe cible    : Billu.lan
```

Lancement via **Launch Campaign** dans l'interface GoPhish.

Email reçu par R.Martinez : 

![email_recu](/components/ATTAQUE_DEFENSE/Ressources/Email_recu_phish.png)


**Résultat observé côté GoPhish (Submitted Data) :**

| Paramètre | Valeur |
| :-- | :-- |
| Utilisateur | `rmartinez@billu.lan` |
| OS victime | Windows 10 |
| Navigateur | Firefox 152.0 |
| Fuseau horaire | Europe/Paris |
| `_original_url` | `https://mail.billu.lan/mail//mail/?_task=login` |
| Action | `login` |
| Horodatage | 13/07/2026 14:36:56 |

La victime a cliqué sur le lien du mail, atterri sur la fausse landing page (clone visuel du webmail), et soumis ses identifiants — capturés intégralement par GoPhish.

![submitted_data](/components/ATTAQUE_DEFENSE/Ressources/Resultat_attaque.png)

---

## 3. Résultat obtenu

**Succès confirmé** : soumission d'identifiants valides par la cible, avec métadonnées complètes (OS, navigateur, fuseau horaire).

**Blocages rencontrés et contournés pendant la mise en place** (documentés car représentatifs des défenses natives d'un serveur mail durci) :

| Blocage rencontré | Cause | Contournement |
| :-- | :-- | :-- |
| `504 Helo command rejected` | Hostname attaquant non FQDN | FQDN configuré (`kali.billu.lan`) |
| `450 Helo command rejected: Host not found` | Pas de résolution DNS du FQDN | Enregistrement DNS ajouté sur l'AD |
| `550 Sender address rejected: User unknown` | Expéditeur non enregistré sur le domaine | Compte `postmaster` valide utilisé |
| `554 SMTP AUTH is required` | Relais non authentifié refusé | Authentification SMTP configurée |

Ces 4 blocages successifs montrent qu'un serveur mail correctement durci impose déjà plusieurs barrières avant même la mise en place d'un antispam dédié — point à valoriser dans l'analyse.

---

## 4. Données / accès obtenus

- Identifiant : `rmartinez@billu.lan`
- Mot de passe : capturé en clair par GoPhish (voir Submitted Data)
- Fonction **Replay Credentials** disponible dans GoPhish pour rejouer ces identifiants sur le vrai service et confirmer l'impact réel

---

## 5. Analyse — Vulnérabilité exploitée

**Vulnérabilité principale** : absence de sensibilisation des utilisateurs face à un email usurpant le support IT avec un prétexte d'urgence (facteur humain).

**Vulnérabilités techniques associées, avant mise en place de la défense** :
- Aucun filtrage anti-phishing/antispam sur le flux entrant
- Absence de vérification SPF/DKIM/DMARC au moment du premier test
- Landing page en HTTP simple (`use_tls: false`), sans alerte navigateur "connexion non sécurisée" qu'un vrai déploiement HTTPS déclencherait

**Comment l'éviter** : chacune des 4 barrières SMTP contournées lors de la mise en place (FQDN, DNS, expéditeur valide, authentification) est déjà un premier niveau de défense ; un filtrage de contenu (Rspamd) constitue la couche suivante, testée en section défense ci-dessous.

---

## 6. Recommandations de durcissement

- Filtrage anti-phishing en amont (voir section Défense)
- SPF / DKIM / DMARC en politique stricte (`p=reject`)
- MFA sur les comptes utilisateurs pour limiter l'impact d'un vol d'identifiants
- Formation et simulations de phishing récurrentes
- Passage de la landing page en HTTPS pour évaluer si un vrai attaquant chercherait à l'imiter plus finement

---

---

# Défense — Filtrage anti-phishing avec Rspamd

## Contexte

| Élément | Valeur |
| :-- | :-- |
| Machine défense | Serveur mail — `mail.billu.lan` |
| Outil | Rspamd 3.12.1 + Redis |
| Intégration | Milter Postfix (port `11332`) |
| Interface web | `0.0.0.0:11334` |
| Règle personnalisée | Script Lua `SUSPICIOUS_URGENCY_WORDS` |

---

## 1. Paramétrage — Installation et configuration

```bash
sudo apt install rspamd redis-server
sudo systemctl enable --now redis-server
```

**Intégration Postfix** (`/etc/postfix/main.cf`) :
```
smtpd_milters = inet:localhost:11332
non_smtpd_milters = inet:localhost:11332
milter_default_action = accept
milter_protocol = 6
```

**Règle personnalisée** — `/etc/rspamd/rspamd.local.lua` :
```lua
local function check_urgency(task)
  local keywords = {
    'expire', 'action requise', 'suspendu', 'urgent',
    'vérifier votre compte', 'verifier votre compte'
  }
  local parts = task:get_text_parts()
  if parts then
    for _, part in ipairs(parts) do
      local raw_content = part:get_content()
      if raw_content then
        local content = tostring(raw_content):lower()
        for _, word in ipairs(keywords) do
          if content:find(word:lower(), 1, true) then
            task:insert_result('SUSPICIOUS_URGENCY_WORDS', 1.0, word)
            return true
          end
        end
      end
    end
  end
  return false
end

rspamd_config:register_symbol({
  name = 'SUSPICIOUS_URGENCY_WORDS',
  score = 5.0,
  description = 'Contient des mots-cles urgence typiques du phishing',
  callback = check_urgency
})
```

---

## 2. Test — Rejeu de la campagne GoPhish

Relance de la campagne de phishing (section attaque) avec Rspamd actif en interception.

```bash
rspamc -h localhost:11334 < email_capture.eml
```

**Résultat observé dans l'History Rspamd :**

| IP | Score | Action | Symboles clés |
| :-- | :-- | :-- | :-- |
| `172.16.0.5` (1er envoi) | `12.21 / 15` | `add header` | `SUSPICIOUS_URGENCY_WORDS`, `MIME_HTML_ONLY`, `SUBJECT_ENDS_SPACES` |
| `172.16.0.5` (renvoi) | `16.60 / 15` | **`reject`** | `SUSPICIOUS_URGENCY_WORDS`, `SPAM_FLAG` |

![history_phishing](/components/ATTAQUE_DEFENSE/Ressources/rejet_mail_phish.png)

 Sur le second envoi, le score dépasse le seuil `reject = 15` défini dans la configuration — l'email est **bloqué avant d'atteindre la boîte de réception** de la victime.

---

## 3. Résultat — Test de comparaison (email légitime)

Envoi d'un email neutre, sans mots-clés d'urgence, entre deux comptes internes :

```bash
rspamc -h localhost:11334 < test_legitime.eml
```

![mail_legitime](/components/ATTAQUE_DEFENSE/Ressources/mail_legitime.png)

**Résultat observé :**

| Type d'email | Score | Action | `SUSPICIOUS_URGENCY_WORDS` |
| :-- | :-- | :-- | :-- |
| Légitime (réunion d'équipe) | proche de `0 / 15` | `no action` | Non déclenché |
| Phishing GoPhish | `12.21` à `16.60 / 15` | `add header` / `reject` | Déclenché |

---

## 4. Tableau de correspondance attaque → alerte détectée

| Attaque lancée | Symbole Rspamd | Détecté | Action |
| :-- | :-- | :-- | :-- |
| Phishing GoPhish (urgence + lien de connexion) | `SUSPICIOUS_URGENCY_WORDS` | Oui | add header / reject |
| Email légitime (contrôle) | — | Non déclenché (attendu) | no action |

---

## 5. Analyse des faux positifs et faux négatifs

**Faux positifs** : aucun observé sur le test de contrôle — l'email légitime, ne contenant aucun des mots-clés définis, n'a déclenché aucune alerte, ce qui confirme que la règle cible bien un vocabulaire spécifique au phishing plutôt qu'un langage courant.

**Faux négatifs potentiels** : la règle repose sur une liste de mots-clés fixes (`expire`, `urgent`, `suspendu`, etc.). Un attaquant reformulant son message sans ces termes précis (ex : synonymes, fautes volontaires, langue différente) contournerait la détection — limite inhérente à une approche par mots-clés statiques plutôt que par analyse sémantique ou apprentissage automatique (Bayes).

---

## 6. Recommandations — Améliorations de la détection

- Étendre la liste de mots-clés avec des variantes et synonymes (ex : "compte bloqué", "confirmer votre identité")
- Passer la politique DMARC de `p=quarantine` à `p=reject` pour un blocage strict des échecs d'authentification
- Ajouter une règle de détection sur les liens (URL de la landing page) plutôt que uniquement sur le texte, pour couvrir les cas où le corps du mail est très court (ex : image seule, lien nu)
