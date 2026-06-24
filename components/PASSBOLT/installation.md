
# Installation de Passbolt CE sur serveur LAMP (Debian 13)

## Pré-requis constatés au départ

Le serveur (`BV-130-138` — Debian 13.5) ne disposait que d'**Apache2** déjà installé et utilisé pour un site existant (`interne.BillU.lan`). PHP et MariaDB étaient absents.

## 1. Installation de MariaDB

```bash
sudo apt update
sudo apt install -y mariadb-server mariadb-client
sudo systemctl enable --now mariadb
sudo mariadb-secure-installation
```


## 2. Installation de PHP et des extensions nécessaires à Passbolt

bash

```bash
sudo apt install -y php php-cli php-fpm php-mysql php-gd php-intl \
  php-mbstring php-curl php-xml php-zip php-bz2 php-gnupg gnupg unzip curl
```

## 3. Liaison Apache ↔ PHP-FPM

```bash
sudo a2enmod proxy_fcgi setenvif
sudo a2enconf php8.3-fpm
sudo systemctl enable --now php8.3-fpm
sudo systemctl restart apache2
```

## 4. Création de la base de données

```sql
CREATE DATABASE passbolt CHARACTER SET utf8mb4;
CREATE USER 'passboltuser'@'localhost' IDENTIFIED BY '********';
GRANT ALL PRIVILEGES ON passbolt.* TO 'passboltuser'@'localhost';
FLUSH PRIVILEGES;
```

## 5. Ajout du dépôt Passbolt (méthode manuelle)

Le script officiel `passbolt-repo-setup.ce.sh` **refuse de s'exécuter si PHP est déjà installé**. Le dépôt a donc été ajouté manuellement :


```bash
sudo apt install -y apt-transport-https ca-certificates curl gnupg
curl -sS https://download.passbolt.com/pub.key | sudo gpg --dearmor --yes --output /usr/share/keyrings/passbolt-repository.gpg

sudo tee /etc/apt/sources.list.d/passbolt.sources > /dev/null <<EOF
Types: deb
URIs: https://download.passbolt.com/ce/debian
Suites: buster
Components: stable
Signed-By: /usr/share/keyrings/passbolt-repository.gpg
EOF

sudo apt update
```

## 6. Installation du paquet

```bash
sudo apt install -y passbolt-ce-server
```

Réponses données aux invites Debconf :

- **Create a passbolt database ?** → `No` (gestion manuelle de la base)
- **Do you want to configure the nginx server ?** → `No` (vhost Apache géré manuellement)

## 7. Génération de la clé GPG serveur

```bash
sudo mkdir -p /var/www/.gnupg
sudo chown www-data:www-data /var/www/.gnupg
sudo chmod 700 /var/www/.gnupg

sudo -H -u www-data gpg --batch --no-tty --gen-key <<EOF
Key-Type: RSA
Key-Length: 3072
Key-Usage: sign,cert
Subkey-Type: RSA
Subkey-Usage: encrypt
Subkey-Length: 3072
Name-Real: Passbolt Server
Name-Email: passbolt@billu.lan
Expire-Date: 0
%no-protection
%commit
EOF
```

Export des clés :

```bash
sudo mkdir -p /etc/passbolt/gpg
sudo -H -u www-data bash -c "gpg --armor --export-secret-keys passbolt@billu.lan > /etc/passbolt/gpg/serverkey_private.asc"
sudo -H -u www-data bash -c "gpg --armor --export passbolt@billu.lan > /etc/passbolt/gpg/serverkey.asc"
sudo chown www-data:www-data /etc/passbolt/gpg/serverkey.asc /etc/passbolt/gpg/serverkey_private.asc
sudo chmod 640 /etc/passbolt/gpg/serverkey.asc /etc/passbolt/gpg/serverkey_private.asc
```

Récupération de l'empreinte (fingerprint) de la **clé maître**  :

```bash
sudo -H -u www-data gpg --list-keys --with-colons passbolt@billu.lan | grep ^fpr
```

## 8. Configuration de /etc/passbolt/passbolt.php

Voir détail complet dans `CONFIGURATION.md`.

## 9. Installation de la structure applicative

```bash
sudo -H -u www-data /usr/share/php/passbolt/bin/cake passbolt install --no-admin
```

## 10. Création du compte administrateur

```bash
sudo -H -u www-data /usr/share/php/passbolt/bin/cake passbolt register_user \
  -u postmaster@billu.lan -f Prenom -l Nom -r admin
```

La commande retourne une **URL d'enregistrement à usage unique** (`/setup/start/...`), à ouvrir depuis un navigateur du LAN pour finaliser la création du compte (installation de l'extension navigateur + génération de la clé GPG personnelle + passphrase).

## 11. Vérification finale

```bash
sudo -H -u www-data /usr/share/php/passbolt/bin/cake passbolt healthcheck
```

---
