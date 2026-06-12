# Configuration du serveur de messagerie BillU

## Architecture

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
MAIL01 Debian 13
        │
        ▼
Script sync_ad_mail.sh
        │
        ▼
MariaDB iRedMail
        │
        ▼
Boîtes mail utilisateurs
```

---

## Configuration réseau

### MAIL01

Adresse IP :

```text
10.0.3.10/24
```

Passerelle :

```text
10.0.3.1
```

DNS :

```text
172.16.130.253
```

---

## Domaine de messagerie

```text
billu.lan
```

---

## Comptes de service

### svc-iredmail

Utilisation :

* Lecture du partage SMB
* Accès au fichier CSV Active Directory

Droits :

* Lecture du partage mail
* Lecture NTFS du dossier partagé

---

## Base de données

Base :

```text
vmail
```

Table principale :

```text
mailbox
```

Table de redirection :

```text
forwardings
```

---

## Structure Maildir

Exemple :

```text
billu.lan/r/m/a/rmartinez-2026.06.10.15.18.19/
```

---

## Synchronisation Active Directory

Le script PowerShell exporte :

```text
SamAccountName
Mail
```

Exemple :

```csv
"lduval","lduval@BillU.lan"
"radvezekt","radvezekt@BillU.lan"
```

---

## Automatisation

### Contrôleur de domaine

Export CSV automatique :

```powershell
Export-MailUsers.ps1
```

### Serveur Mail

Synchronisation :

```bash
sync_ad_mail.sh
```

---

## Sécurité

Mot de passe stocké :

```text
SSHA512
```

Les mots de passe ne sont jamais enregistrés en clair dans MariaDB.

---

## Résultat obtenu

* 190 boîtes mail créées automatiquement.
* Synchronisation Active Directory vers iRedMail.
* Gestion centralisée des utilisateurs.
* Réduction des opérations manuelles d'administration.
