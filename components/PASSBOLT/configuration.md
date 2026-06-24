
# Configuration de Passbolt

## 1. Configuration Apache

### Vhost dédié /etc/apache2/sites-available/passbolt.conf


```apache
<VirtualHost *:80>
    ServerName passbolt.BillU.lan
    DocumentRoot /usr/share/php/passbolt/webroot

    <Directory /usr/share/php/passbolt/webroot>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/passbolt_error.log
    CustomLog ${APACHE_LOG_DIR}/passbolt_access.log combined
</VirtualHost>

<VirtualHost *:443>
    ServerName passbolt.BillU.lan
    DocumentRoot /usr/share/php/passbolt/webroot

    <Directory /usr/share/php/passbolt/webroot>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    SSLEngine on
    SSLCertificateFile /etc/ssl/passbolt/passbolt.crt
    SSLCertificateKeyFile /etc/ssl/passbolt/passbolt.key

    ErrorLog ${APACHE_LOG_DIR}/passbolt_error.log
    CustomLog ${APACHE_LOG_DIR}/passbolt_access.log combined
</VirtualHost>
```

Activation :


```bash
sudo a2enmod rewrite ssl
sudo a2ensite passbolt.conf
sudo systemctl reload apache2
```

### Fichier `.htaccess` (webroot)

Indispensable pour le routage interne de CakePHP/Passbolt — absent par défaut sur cette installation, à recréer manuellement si besoin :

`/usr/share/php/passbolt/webroot/.htaccess` :

```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^ index.php [L]
</IfModule>
```

## 2. Certificat SSL du vhost web

Auto-signé, généré avec :

```bash
sudo openssl req -x509 -nodes -days 825 -newkey rsa:2048 \
  -keyout /etc/ssl/passbolt/passbolt.key \
  -out /etc/ssl/passbolt/passbolt.crt \
  -subj "/CN=passbolt.BillU.lan"
```

## 3. Résolution DNS

Enregistrement A créé dans la zone AD DNS `BillU.lan` :

|Nom|FQDN|IP|
|---|---|---|
|passbolt|passbolt.BillU.lan|172.16.130.138|

## 4. Fichier `/etc/passbolt/passbolt.php`

### Connexion base de données


```php
'Datasources' => [
    'default' => [
        'host' => 'localhost',
        'port' => env('DATASOURCES_DEFAULT_PORT', 3306),
        'username' => 'passboltuser',
        'password' => '********',
        'database' => 'passbolt',
    ],
],
```

### URL de base de l'application

```php
'App' => [
    'fullBaseUrl' => 'https://passbolt.BillU.lan',
],
```

### Clé GPG serveur

```php
'passbolt' => [
    'gpg' => [
        'serverKey' => [
            'fingerprint' => '4EAF8C08703E245D7843534661371E841B5E6053',
            'public' => '/etc/passbolt/gpg/serverkey.asc',
            'private' => '/etc/passbolt/gpg/serverkey_private.asc',
        ],
    ],
],
```

### Transport email (configuration de référence — voir section 5 pour le réglage final retenu)


```php
'EmailTransport' => [
    'default' => [
        'className' => 'Smtp',
        'host' => '10.0.3.10',
        'port' => 25,
        'timeout' => 30,
        'username' => 'passbolt@BillU.lan',
        'password' => '********',
        'tls' => false,
    ],
],
'Email' => [
    'default' => [
        'from' => ['passbolt@BillU.lan' => 'Passbolt'],
    ],
],
```

## 5. Configuration SMTP (serveur de messagerie)

### Solution retenue

Bascule du transport SMTP sur le **port 25, sans TLS**, flux restant interne au LAN/DMZ de l'établissement :

- Configuration appliquée via l'interface web **Administration → Serveur mail** (la configuration SMTP est gérée en base de données depuis l'interface, et non plus uniquement via `passbolt.php`)
- Host : `10.0.3.10`
- Port : `25`
- TLS : désactivé

## 6. Comptes et organisation des secrets

|Élément|Détail|
|---|---|
|Compte admin|`postmaster@billu.lan`|
|Dossiers créés|`GLPI - rmartinez`, `GLPI - sandersson`|
|Méthode de partage|Invitation par email → installation extension navigateur → génération clé GPG personnelle|
