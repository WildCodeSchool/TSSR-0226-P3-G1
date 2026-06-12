# BillU - Serveur de Messagerie

## Présentation du projet

Ce projet a été réalisé dans le cadre de la formation TSSR (Technicien Supérieur Systèmes et Réseaux) à la Wild Code School.

L'objectif du projet est de déployer une infrastructure de messagerie interne basée sur iRedMail et d'automatiser la création des boîtes mail à partir des utilisateurs présents dans l'Active Directory de l'entreprise BillU.

---

## Objectifs

* Déployer un serveur de messagerie sous Linux.
* Fournir un accès aux boîtes mail via Webmail, IMAP et SMTP.
* Centraliser la gestion des utilisateurs à l'aide de l'Active Directory.
* Automatiser la création des boîtes mail.
* Réduire les tâches d'administration manuelles.

---

## Architecture du projet

```text
Active Directory
        │
        ▼
Export CSV PowerShell
        │
        ▼
Partage SMB
        │
        ▼
Serveur Mail Debian 13
        │
        ▼
Script Bash de synchronisation
        │
        ▼
MariaDB / iRedMail
        │
        ▼
Boîtes mail utilisateurs
```

---

## Technologies utilisées

### Infrastructure

* Windows Server
* Active Directory
* DNS
* SMB

### Serveur de messagerie

* Debian 13
* iRedMail
* MariaDB
* Postfix
* Dovecot
* Roundcube

### Automatisation

* PowerShell
* Bash

---

## Fonctionnement

### Export des utilisateurs Active Directory

Un script PowerShell exporte automatiquement les utilisateurs de l'Active Directory au format CSV.

Exemple :

```csv
"SamAccountName","Mail"
"lduval","lduval@BillU.lan"
"radvezekt","radvezekt@BillU.lan"
```

### Partage du fichier CSV

Le fichier est déposé dans un partage SMB accessible depuis le serveur de messagerie.

Compte utilisé :

```text
svc-iredmail
```

### Synchronisation automatique

Le script Bash :

```bash
sync_ad_mail.sh
```

effectue les opérations suivantes :

1. Lecture du fichier CSV.
2. Vérification de l'existence du compte dans iRedMail.
3. Génération du mot de passe chiffré (SSHA512).
4. Création de la boîte mail dans MariaDB.
5. Création des entrées de forwarding nécessaires au fonctionnement d'iRedMail.

---

## Résultats obtenus

* Synchronisation des utilisateurs Active Directory.
* Création automatique des boîtes mail.
* Plus de 190 comptes générés automatiquement.
* Centralisation de la gestion des utilisateurs.
* Réduction significative des tâches d'administration.

---

## Structure du dépôt

```text
.
├── README.md
├── INSTALLATION.md
├── CONFIGURATION.md
├── sync_ad_mail.sh
├── Export-MailUsers.ps1
└── docs/
```

---

## Installation et configuration

Pour reproduire l'environnement :

* Consulter le fichier INSTALLATION.md
* Consulter le fichier CONFIGURATION.md

---

## Sécurité

Les mots de passe des utilisateurs sont stockés sous forme chiffrée à l'aide de l'algorithme SSHA512.

Aucun mot de passe n'est enregistré en clair dans la base de données MariaDB.

---

## Conclusion

Cette solution permet d'intégrer automatiquement les utilisateurs Active Directory au serveur de messagerie iRedMail grâce à une chaîne d'automatisation basée sur PowerShell, SMB, Bash et MariaDB.

Le projet répond aux besoins de gestion centralisée des utilisateurs tout en limitant les interventions manuelles des administrateurs systèmes.
