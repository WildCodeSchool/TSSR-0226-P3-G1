## Durcissement Active Directory (résultats ADcheck)

### Description générale

Un audit a été réalisé avec l'outil **ADcheck** afin d'identifier les vulnérabilités de configuration sur l'Active Directory et les postes du domaine. Les résultats sont classés ci-dessous par thématique, avec pour chaque point : le risque associé et la recommandation de correction.

---

### 1 Comptes utilisateurs et privilèges

![adcheck](/components/AUDIT/Ressources/adcheck5.png)


| Constat | Risque | Recommandation |
|---|---|---|
| Comptes admin : `Administrator`, `DLGUSER01`, `XC-T0`, `PCADMIN`, `SVC_WDS` | Surface d'attaque élevée si tous ces comptes ont des droits Domain Admin | Revoir le besoin réel de chaque compte, appliquer le principe du moindre privilège (tiering T0/T1/T2) |
| Comptes admin **non présents** dans le groupe **Protected Users** : `DLGUSER01`, `XC-T0`, `PCADMIN`, `SVC_WDS` | Ces comptes restent vulnérables au vol de credentials (NTLM, Kerberos, WDigest) | Ajouter les comptes sensibles au groupe **Protected Users** |
| Comptes admin **délégables** (non protégés contre la délégation) : `XC-T0`, `PCADMIN`, `SVC_WDS` | Un attaquant compromettant un service peut usurper l'identité de ces comptes via la délégation Kerberos | Cocher "Le compte est sensible et ne peut pas être délégué" sur ces comptes |
| Compte natif **Administrator** utilisé récemment (13 jours) | Le compte administrateur intégré ne devrait jamais être utilisé au quotidien | Désactiver le compte Administrator natif après création des comptes d'administration nominatifs |
| **6 comptes** avec mot de passe n'expirant jamais | Augmente la fenêtre d'exploitation en cas de compromission | Réactiver l'expiration de mot de passe, sauf justification technique documentée |
| Compte machine avec mot de passe non requis : `ECOTECHSOLUTION$` | Un compte sans mot de passe requis peut être authentifié sans credential valide | Vérifier et retirer le flag `PASSWD_NOTREQD` sur ce compte |

**Points positifs constatés :** aucun compte vulnérable au Kerberoasting, à l'AS-REP Roasting, au Timeroasting, ni au Time-based Roasting ; pas de mot de passe réversible ; pas de compte verrouillé ; pas de compte inactif ; aucun compte dans le groupe Schema Admins.

---

### 2 Durcissement système (postes / serveurs)


![adcheck](/components/AUDIT/Ressources/adcheck4.png)


| Constat | Risque | Recommandation |
|---|---|---|
| **Credential Guard** désactivé | Les secrets d'authentification (hash NTLM, tickets Kerberos) sont exposés en mémoire | Activer Credential Guard via GPO sur les postes compatibles |
| **AppLocker** non configuré | Aucune restriction sur l'exécution de binaires/scripts non autorisés | Définir des règles AppLocker (whitelisting applicatif) |
| **gpp_autologon** activé | Des identifiants en clair peuvent être stockés dans les Préférences GPO | Auditer et supprimer toute GPP contenant des identifiants (`gpp-decrypt`) |
| **BitLocker** désactivé | Données non protégées en cas de vol/perte physique du poste | Activer BitLocker sur tous les postes, en particulier les portables |
| **Pare-feu désactivé** | Aucun filtrage réseau local | Réactiver le pare-feu Windows avec profils adaptés (Domaine/Privé/Public) |
| **LLMNR / NetBIOS / mDNS** activés | Vulnérable aux attaques de type LLMNR/NBT-NS Poisoning (capture de hash NTLM) | Désactiver LLMNR (GPO), NetBIOS (DHCP option 44/config carte réseau) et mDNS |
| **LSASS** ne tourne pas en processus protégé | Facilite l'extraction de credentials (type Mimikatz) | Activer `RunAsPPL` pour LSASS via GPO/registre |
| **PowerShell v2** activé | Contourne l'AMSI et la journalisation avancée de PowerShell | Désactiver la fonctionnalité PowerShell v2 (`Disable-WindowsOptionalFeature`) |
| **Journalisation PowerShell** désactivée | Absence de traçabilité en cas d'exécution de scripts malveillants | Activer Script Block Logging et Module Logging via GPO |
| **PowerShell Constrained Language Mode** non configuré | Les scripts ont un accès complet à .NET, facilitant l'exécution de payloads | Configurer le mode restreint via AppLocker/WDAC |
| **RDP non protégé contre le Pass-the-Hash** | Un attaquant avec un hash volé peut rebondir via RDP | Activer Restricted Admin Mode / Remote Credential Guard |
| **Timeout de session RDP** non défini | Sessions RDP ouvertes indéfiniment, surface d'attaque accrue | Définir un délai d'inactivité et de déconnexion RDP via GPO |
| **WDigest** activé | Stocke les mots de passe en clair en mémoire (LSA) | Désactiver WDigest via GPO (`UseLogonCredential = 0`) |
| **WPAD** activé | Vulnérable aux attaques de type WPAD Spoofing / NTLM relay | Désactiver WPAD si non utilisé (service WinHttpAutoProxySvc, GPO) |
| **Windows Script Host** activé | Permet l'exécution de scripts `.vbs`/`.js`, souvent utilisés par des malwares | Désactiver WSH via GPO si non nécessaire métier |
| **WSUS non sécurisé** | Vulnérable à l'attaque WSUS (injection de faux correctifs si HTTP non chiffré) | Configurer WSUS en HTTPS |
| **Trop de logons conservés dans le cache LSA** | Augmente la surface d'attaque en cas d'extraction mémoire | Réduire la valeur `CachedLogonsCount` |

**Points positifs constatés :** UAC configuré de façon sécurisée, hash LM désactivé, authentification limitée à NTLMv2, AMSI actif (Windows Defender), NLA activée sur RDP, MSI non installés avec élévation systématique.

---

### 3 Politique de mots de passe et Kerberos


![adcheck](/components/AUDIT/Ressources/adcheck3.png)


| Constat | Risque | Recommandation |
|---|---|---|
| Chiffrement Kerberos supporté : **RC4_HMAC_MD5** | Algorithme faible, cassable hors-ligne, permet des attaques de type Kerberoasting facilitées | Forcer AES128/AES256 uniquement (GPO "Configure encryption types allowed for Kerberos") |
| `pwdReversibleEncryption` : false | ✅ Conforme | — |
| `pwdComplexity` : true | ✅ Conforme | — |
| `pwdHistoryLength` : 60 | ✅ Bonne pratique | — |
| `MaxTicketAge` : 10h | Conforme aux recommandations par défaut | Vérifier cohérence avec la politique de renouvellement (`MaxRenewAge`) |

---

### 4 Permissions (ACL) sur l'annuaire AD


![adcheck](/components/AUDIT/Ressources/adcheck2.png)


| Objet | Constat | Risque | Recommandation |
|---|---|---|---|
| `CN=Users,DC=BillU,DC=lan` | **Authenticated Users** : lecture des propriétés et du contenu | Risque limité (lecture seule), mais expose des informations à tout utilisateur authentifié | Restreindre si le conteneur contient des comptes sensibles |
| `DC=BillU,DC=lan` (racine du domaine) | **Authenticated Users** dispose des droits étendus : *Enable-Per-User-Reversibly-Encrypted-Password*, *Unexpire-Password*, *Update-Password-Not-Required-Bit* | Un utilisateur standard authentifié pourrait, sous certaines conditions, retirer l'expiration de mot de passe ou lever l'obligation de mot de passe sur des comptes | Retirer ces droits étendus du groupe Authenticated Users au niveau de la racine du domaine ; les réserver aux comptes d'administration |
| `DC=BillU,DC=lan` | **Everyone** dispose de *Delete all child objects* | Risque critique : suppression potentielle d'objets AD par n'importe quel utilisateur | Retirer immédiatement ce droit, il ne doit être accordé qu'aux comptes d'administration délégués |

---

### 5 Permissions sur les partages réseau (SYSVOL / NETLOGON / partages métier)


![adcheck](/components/AUDIT/Ressources/adcheck.png)


| Partage | Constat | Risque | Recommandation |
|---|---|---|---|
| `\\<DC>\mail` | **Everyone** : Read & Execute sur dossiers/fichiers/sous-dossiers | Accès en lecture non maîtrisé à un partage potentiellement sensible (contenu mail) | Remplacer "Everyone" par un groupe de sécurité dédié avec accès restreint aux utilisateurs concernés |
| `\\<DC>\NETLOGON` | **Authenticated Users** : Read & Execute | Conforme au fonctionnement standard AD (nécessaire pour l'application des scripts de logon/GPO) | Aucune action requise, mais vérifier l'absence de scripts contenant des identifiants |
| `\\<DC>\SYSVOL` | **Authenticated Users** : Read & Execute | Conforme au fonctionnement standard AD | Aucune action requise ; surveiller les modifications de GPO (auditing SYSVOL) |

---

### Synthèse des priorités

1. **Critique** : retirer le droit *Delete all child objects* accordé à "Everyone" sur la racine du domaine.
2. **Critique** : retirer les droits étendus (*Unexpire-Password*, *Update-Password-Not-Required-Bit*, *Reversibly-Encrypted-Password*) du groupe Authenticated Users.
3. **Élevé** : ajouter les comptes admin au groupe Protected Users et interdire leur délégation.
4. **Élevé** : forcer Kerberos en AES uniquement (retirer RC4_HMAC_MD5).
5. **Élevé** : désactiver LLMNR/NetBIOS/mDNS, WDigest, PowerShell v2.
6. **Moyen** : activer Credential Guard, BitLocker, LSASS protégé, journalisation PowerShell.
7. **Moyen** : restreindre l'accès "Everyone" sur le partage `mail`.


## Audit PingCastle

