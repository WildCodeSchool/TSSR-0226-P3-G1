## Pré-requis

Le serveur (`BV-130-138`) dispose déjà d'Apache2 et MariaDB, installés précédemment pour Passbolt (voir documentation Passbolt). Pas de réinstallation nécessaire.

## 1. Installation du paquet Redmine

Contrairement à Passbolt, Redmine est **officiellement packagé pour Debian 13** — aucun dépôt tiers à ajouter.

```bash
sudo apt update
sudo apt install -y redmine-mysql
```

### Prompts Debconf

- **"Configure database for redmine with dbconfig-common ?"** → `Yes` (laisser l'assistant gérer la base automatiquement — contrairement à Passbolt, ça fonctionne de façon fiable ici)
- Mot de passe administrateur de la base : laisser la génération automatique, ou en définir un (stocké dans `/etc/dbconfig-common/redmine.conf`)

La base créée s'appelle **`redmine`**, avec un utilisateur dédié généré automatiquement.

## 2. Installation du connecteur Apache (Phusion Passenger)

Redmine étant en Ruby on Rails, Passenger fait l'équivalent de PHP-FPM pour Ruby :


```bash
sudo apt install -y libapache2-mod-passenger
sudo a2enmod passenger
```

## 3. Création du vhost à partir de l'exemple fourni par le paquet


```bash
sudo cp /usr/share/doc/redmine/examples/apache2-passenger-host.conf /etc/apache2/sites-available/redmine.conf
sudo nano /etc/apache2/sites-available/redmine.conf
```

Adapter le `ServerName` :

```apache
ServerName redmine.BillU.lan
```

Activer le site :

```bash
sudo a2ensite redmine.conf
sudo apache2ctl configtest
sudo systemctl reload apache2
```

## 4. Création de l'enregistrement DNS

Dans l'AD DNS, zone `BillU.lan` → nouvel hôte (A) :

|Nom|FQDN|IP|
|---|---|---|
|redmine|redmine.BillU.lan|172.16.130.138|

## 5. Ajout du support HTTPS

Voir le détail complet du vhost `:443` dans `CONFIGURATION.md`.

Génération du certificat (auto-signé, à remplacer ultérieurement par un certificat AD CS) :


```bash
sudo mkdir -p /etc/ssl/passbolt
sudo openssl req -x509 -nodes -days 825 -newkey rsa:2048 \
  -keyout /etc/ssl/passbolt/redmine.key \
  -out /etc/ssl/passbolt/redmine.crt \
  -subj "/CN=redmine.BillU.lan"

sudo a2enmod ssl
sudo apache2ctl configtest
sudo systemctl reload apache2
```

## 6. Première connexion

```
https://redmine.BillU.lan
```

Identifiants par défaut :

```
login: admin
password: admin
```

⚠️ Mot de passe changé immédiatement après la première connexion (menu **Mon compte → Changer de mot de passe**).

## 7. Configuration de l'authentification LDAP

Voir `CONFIGURATION.md` pour le détail des champs.

## 8. Création du projet et des trackers

Voir `CONFIGURATION.md`.

## 9. Déploiement du raccourci via GPO

Voir `CONFIGURATION.md`, section GPO.
