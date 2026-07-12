# Audit GLPI — glpwnme

Rapport d'audit de sécurité GLPI
Domaine BillU.lan — Audit glpwnme
Date : 12 juillet 2026

---

## 1. Objectif du document

Ce document présente les résultats d'un audit de sécurité de l'instance GLPI hébergée sur le serveur `BV-130-145` (domaine BillU.lan), réalisé à l'aide de l'outil **glpwnme** (Orange Cyberdefense). Il décrit les vulnérabilités identifiées lors de l'audit initial, distingue les faux positifs des vulnérabilités réellement confirmées, présente une preuve d'exploitation (PoC) sur la faille la plus critique, puis détaille le plan de remédiation ainsi que les résultats attendus lors de l'audit de contrôle.

## 2. Méthodologie

L'outil glpwnme permet de vérifier la présence de vulnérabilités connues (CVE) sur une instance GLPI, en comparant la version détectée à une base de failles répertoriées, puis en confirmant certaines d'entre elles par exploitation contrôlée lorsque des identifiants sont fournis.

Installation de l'outil (via `pipx`) :

```bash
apt install git -y
pipx install git+https://github.com/Orange-Cyberdefense/glpwnme
```

Commande de scan complet, authentifié, sans restriction OPSEC (contexte labo) :

```bash
glpwnme -t https://localhost/glpi -u administrator_glpi -p '********' --auth local --check-all --no-opsec
```

**Précision technique** : l'instance redirige automatiquement `http://` vers `https://localhost/glpi` (HTTP 301). Le scan doit être exécuté directement en HTTPS, sous peine d'échec silencieux de l'authentification.

## 3. Audit initial

### 3.1 Informations générales détectées

| Élément | Valeur |
|---|---|
| Version GLPI | **11.0.7** |
| Système d'exploitation | Unix |
| Répertoire racine GLPI | `/var/www/html/glpi` |
| API GLPI | Désactivée |
| Fonction "mot de passe oublié" | Désactivée |
| Module Inventaire | Activé |
| Profil du compte de test utilisé | Super-Admin |

### 3.2 Résultat du scan complet (`--check-all --no-opsec`)

| CVE | Score CVSS | Impact | Privilèges requis | Plage de versions vulnérables | Statut sur cette instance |
|---|---|---|---|---|---|
| CVE_2026_48482 | 7.2 | Remote Code Execution, écriture de fichier arbitraire | Superadmin | 11.0.0 ≤ version < 11.0.8 | **Vulnérable confirmé** |
| CVE_2026_52848 | 5.2 | Contournement MFA | Non authentifié | 11.0.0 ≤ version < 11.0.8 | **Vulnérable confirmé** |
| DEFAULT_PASSWORD_CHECK | 6.0  | Authentication Bypass | Non authentifié | Toutes versions | Non vulnérable (comptes par défaut testés, tous refusés) |
| CVE_2025_32786 | 7.2 | SQL Injection non authentifiée | Non authentifié | Toutes versions (avant correctif) | Non vulnérable |
| CVE_2026_26026 | 7.2 | SSTI (Server Side Template Injection) | Superadmin | 11.0.0 ≤ version < 11.0.6 | Non vulnérable |
| CVE_2026_26263 | 8.1 | SQL Injection, Database Disclosure | Non authentifié | 11.0.0 ≤ version < 11.0.6 | Non vulnérable |
| CVE_2020_15175 → CVE_2025_24799 | — | Diverses (upload PHP, désérialisation, etc.) | Variable | Versions antérieures | Non vulnérable |

**Constat général** : l'instance est globalement bien maintenue — la majorité des CVE connues par l'outil sont déjà corrigées grâce à la version 11.0.7 installée. Deux vulnérabilités restent toutefois exploitables, l'une d'entre elles étant critique.

### 3.3 Vérification des identifiants par défaut

Test des comptes par défaut GLPI (`DEFAULT_PASSWORD_CHECK`) :

| Compte testé | Résultat |
|---|---|
| `glpi:glpi` (Super-Admin) | ❌ Échec |
| `tech:tech` (Technicien) | ❌ Échec |
| `normal:normal` (Utilisateur normal) | ❌ Échec |
| `post-only:postonly` (Post-only) | ❌ Échec |

**Conclusion** : les identifiants par défaut ont bien été changés. Bonne pratique déjà en place, aucune action requise sur ce point.

## 4. Preuve d'exploitation (PoC) — CVE_2026_48482

### 4.1 Description technique

Path traversal authentifié dans la fonctionnalité d'import de formulaire. La méthode `FormSerializer::prepareIllustrationDataForImport()` écrit un fichier `illustration.key` sous `GLPI_TMP_DIR` avec un contenu contrôlé par l'attaquant et sans assainissement du chemin. Une séquence `../` permet d'échapper vers le répertoire `public/` et d'y déposer un webshell PHP, conduisant à une exécution de code à distance (RCE).

**Prérequis** : le compte utilisé doit disposer du droit **"Forms create"**, accordé par défaut uniquement au profil **Super-Admin**.

### 4.2 Déroulement du test

Vérification des droits, sans dépôt de fichier :
```bash
glpwnme -t https://localhost/glpi -e CVE_2026_48482 -u administrator_glpi -p '********' --auth local --check
```

Exploitation avec exécution de la commande `id` via le webshell déposé :
```bash
glpwnme -t https://localhost/glpi -e CVE_2026_48482 -u administrator_glpi -p '********' --auth local --run
```

**Résultat** : dépôt confirmé d'un fichier PHP dans `public/`, exécution de commande système confirmée via le webshell.

### 4.3 Nettoyage post-exploitation

```bash
glpwnme -t https://localhost/glpi -e CVE_2026_48482 -u administrator_glpi -p '********' --auth local --clean
```

Vérification manuelle de l'absence de fichier résiduel :
```bash
find /var/www/glpi/public -name "*.php" -newer /var/www/glpi/index.php
```

## 5. Actions correctives recommandées

| Priorité | Action | Findings corrigés |
|---|---|---|
| **Critique** | Mettre à jour GLPI vers la version 11.0.8 ou supérieure | CVE_2026_48482, CVE_2026_52848 |
| **Élevée** | Restreindre le droit "Forms create" aux comptes strictement nécessaires (moindre privilège), en attendant la mise à jour | CVE_2026_48482 |
| **Moyenne** | Surveiller les écritures inattendues de fichiers `.php` dans `public/` (détection d'exploitation) | CVE_2026_48482 |
| **Moyenne** | Vérifier la configuration MFA après mise à jour (le contournement ne doit plus être possible) | CVE_2026_52848 |
| **Faible** | Maintenir la politique actuelle sur les comptes par défaut (déjà conforme) | DEFAULT_PASSWORD_CHECK |

## 6. Audit final

Un second scan glpwnme devra être exécuté après la mise à jour de GLPI vers la version 11.0.8+, afin de confirmer la disparition de CVE_2026_48482 et CVE_2026_52848 :

```bash
glpwnme -t https://localhost/glpi -u administrator_glpi -p '********' --auth local --check-all --no-opsec
```

## 7. Synthèse comparative

| Indicateur | Audit initial | Audit final |
|---|---|---|
| Version GLPI | 11.0.7 | *à renseigner* |
| CVE vulnérables confirmées | 2 (1 critique, 1 moyenne) | *à renseigner* |
| CVE non vulnérables | 20+ | *à renseigner* |

## 8. Recommandations et prochaines étapes

- Appliquer la mise à jour GLPI vers 11.0.8+ dans les meilleurs délais (correctif des deux vulnérabilités confirmées).
- Relancer un scan glpwnme après mise à jour pour valider la remédiation et documenter l'audit final.
