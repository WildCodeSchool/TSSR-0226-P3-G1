## Solution retenue

**Passbolt CE (Community Edition)**, version installée : **5.13.0** (CakePHP 5.3.6).

Passbolt a été choisi plutôt que Bitwarden/Vaultwarden car :

- Installation native sur une stack **LAMP** déjà existante
- Orienté équipe, avec gestion fine des partages de mots de passe par utilisateur/dossier
- Chiffrement bout-en-bout basé sur **GPG**, clé privée jamais transmise au serveur

## Architecture

Passbolt a été mutualisé sur un serveur web interne déjà existant, plutôt que sur une VM dédiée, car :

- Le serveur est **strictement accessible depuis le LAN** (aucune exposition internet)
- Le service est isolé du site déjà en place via un **vhost Apache dédié** (nom de domaine différent, base de données dédiée)

```
Serveur web interne (Debian 13 — BV-130-138 — 172.16.130.138)
 ├── Apache2 (vhost "interne.BillU.lan" — site existant, non modifié)
 ├── Apache2 (vhost "passbolt.BillU.lan" — Passbolt, ajouté)
 ├── MariaDB (base dédiée "passbolt")
 └── PHP 8.3 (PHP-FPM)
```

Le serveur mail (iRedMail, en DMZ — 10.0.3.10) est utilisé comme relais SMTP pour l'envoi des emails Passbolt (invitations, notifications de partage).

## Accès

|Élément|Valeur|
|---|---|
|URL d'administration / utilisation|`https://passbolt.BillU.lan`|
|Authentification|Extension navigateur Passbolt + clé GPG personnelle (passphrase)|
|Compte admin|`postmaster@billu.lan` (rôle admin)|

## Fonctionnalités validées

-  Connexion web via navigateur + extension Passbolt
-  Création de comptes utilisateurs et invitation par email
-  Organisation des mots de passe par dossiers (ex: `GLPI - rmartinez`, `GLPI - sandersson`)
-  Partage de mots de passe entre utilisateurs
-  Envoi d'emails (invitations / notifications) via relais SMTP interne

## Documentation associée

- `INSTALLATION.md` — étapes détaillées de l'installation, dans l'ordre chronologique réel (y compris les erreurs rencontrées et leurs résolutions)
- `CONFIGURATION.md` — détail des fichiers de configuration (Apache, Passbolt, GPG, SMTP)

## Points de vigilance pour la suite

- Le certificat SSL du vhost Passbolt est actuellement **auto-signé** → à terme, faire signer un certificat par l'AD CS interne (`BillU-CA`) pour éviter l'avertissement de sécurité dans les navigateurs
- L'envoi SMTP fonctionne actuellement en **port 25 sans TLS** (contournement du problème de validation de certificat AD CS). À sécuriser si le flux LAN → DMZ n'est pas déjà cloisonné par ailleurs
