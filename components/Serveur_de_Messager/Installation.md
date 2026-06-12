# Installation du serveur de messagerie BillU

## Présentation

Ce document décrit l'installation et la configuration du serveur de messagerie BillU basé sur Debian 13 et iRedMail.

L'objectif est de permettre la création automatique des boîtes mail à partir des utilisateurs présents dans l'Active Directory BillU.

---

## Prérequis

### Infrastructure

* Contrôleur de domaine Active Directory
* Serveur DNS BillU
* Serveur de messagerie Debian 13
* Partage SMB accessible depuis le serveur mail
* Domaine Active Directory : billu.lan

### Configuration réseau

| Équipement            | Adresse IP     |
| --------------------- | -------------- |
| Contrôleur de domaine | 172.16.130.253 |
| Serveur Mail          | 10.0.3.10      |
| pfSense DMZ           | 10.0.3.1       |

---

## Installation de Debian 13

Mettre à jour le système :

```bash
apt update && apt upgrade -y
```

Installer les outils nécessaires :

```bash
apt install sudo wget curl vim net-tools smbclient cifs-utils -y
```

---

## Installation iRedMail

Télécharger iRedMail :

```bash
wget https://github.com/iredmail/iRedMail/archive/refs/tags/1.7.4.tar.gz
```

Extraction :

```bash
tar xvf 1.7.4.tar.gz
cd iRedMail-*
```

Lancement de l'installation :

```bash
bash iRedMail.sh
```

Choix effectués :

* Stockage : MariaDB
* Domaine : billu.lan
* Webmail : Roundcube
* Répertoire mail : /var/vmail

---

## Vérification des services

```bash
systemctl status mariadb
systemctl status postfix
systemctl status dovecot
```

---

## Création du partage SMB

Création du dossier :

```powershell
mkdir C:\Users\Administrator.BV-100-101\Desktop\mail
```

Partage :

Nom :

```text
mail
```

Droits :

* svc-iredmail : Lecture
* Administrateurs : Contrôle total

---

## Montage du partage SMB sur MAIL01

Création du point de montage :

```bash
mkdir -p /mnt/ad
```

Connexion au partage :

```bash
smbclient //172.16.130.253/mail -U "BILLU\svc-iredmail"
```

---

## Export des utilisateurs Active Directory

Script PowerShell :

```powershell
Get-ADUser -Filter * `
-SearchBase "OU=BU_Users,DC=billu,DC=lan" `
-Properties Mail |
Select SamAccountName,Mail |
Export-Csv "C:\Users\Administrator.BV-100-101\Desktop\mail\UtilisateursMails.csv" `
-NoTypeInformation -Encoding UTF8
```

---

## Synchronisation des comptes

Script Bash :

```bash
/root/sync_ad_mail.sh
```

Fonctionnement :

1. Lecture du CSV Active Directory.
2. Vérification de l'existence de la boîte mail.
3. Génération du hash SSHA512.
4. Création automatique dans MariaDB.
5. Création des entrées de forwarding.

---

## Vérification

Connexion MariaDB :

```bash
mysql -u root -p
```

```sql
USE vmail;
SELECT COUNT(*) FROM mailbox;
```

Connexion utilisateur :

* Webmail Roundcube
* IMAP
* SMTP

Le compte est créé automatiquement à partir de l'utilisateur Active Directory.
