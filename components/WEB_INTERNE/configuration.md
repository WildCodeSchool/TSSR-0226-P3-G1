# Sommaire

- [**1. Configuration Apache**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#1-configuration-apache)
    - [**1.1 Vérification du service**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#11-v%C3%A9rification-du-service)
    - [**1.2 Configuration du VirtualHost**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#12-configuration-du-virtualhost)
    - [**1.3 Vérification de la syntaxe**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#13-v%C3%A9rification-de-la-syntaxe)
    - [**1.4 Déploiement du portail**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#14-d%C3%A9ploiement-du-portail)
- [**2. Configuration DNS interne**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#2-configuration-dns-interne)
    - [**2.1 Ajout de l'enregistrement**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#21-ajout-de-lenregistrement)
    - [**2.2 Vérification**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#22-v%C3%A9rification)
- [**3. Configuration GPO Active Directory**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#3-configuration-gpo-active-directory)
    - [**3.1 Création de la GPO**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#31-cr%C3%A9ation-de-la-gpo)
    - [**3.2 Configuration du raccourci**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#32-configuration-du-raccourci)
    - [**3.3 Liaison de la GPO**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#33-liaison-de-la-gpo)
    - [**3.4 Vérification**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#34-v%C3%A9rification)

---

# 1. Configuration Apache

## 1.1 Vérification du service

- Vérifier que Apache est bien actif :

```bash
systemctl status apache2
```

- Vérifier que Apache écoute bien sur le port 80 :

```bash
ss -tlnp | grep 80
```

- Résultat attendu :

```
LISTEN 0  128  0.0.0.0:80  0.0.0.0:*  users:(("apache2",...))
```

## 1.2 Configuration du VirtualHost

- Éditer le VirtualHost par défaut :

```bash
nano /etc/apache2/sites-available/000-default.conf
```

- Contenu du fichier :

```apache
<VirtualHost *:80>
    ServerAdmin contact@billu.fr
    DocumentRoot /var/www/html
    ServerName interne.billu.lan

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

- Recharger Apache pour appliquer les changements :

```bash
systemctl reload apache2
```

## 1.3 Vérification de la syntaxe

- Avant tout redémarrage, toujours vérifier la syntaxe :

```bash
apachectl configtest
```

- Résultat attendu :

```
Syntax OK
```

## 1.4 Déploiement du portail

- Copier le fichier du portail depuis votre poste :

```bash
scp interne.html root@172.16.130.138:/var/www/html/index.html
```

- Appliquer les bonnes permissions :

```bash
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/
```

- Vérifier que le portail est accessible depuis le serveur :

```bash
curl -I http://localhost
```

- Résultat attendu :

```
HTTP/1.1 200 OK
Server: Apache/2.4.x (Debian)
```

---

# 2. Configuration DNS interne

## 2.1 Ajout de l'enregistrement

Pour accéder au portail via un nom de domaine depuis le LAN :

- Aller dans **Services → DNS Resolver → Host Overrides → Add**

|Champ|Valeur|
|---|---|
|Host|`interne`|
|Domain|`billu.lan`|
|IP|`172.16.130.138`|
|Description|Portail interne BillU|

- Cliquer **Save** puis **Apply Changes**.

## 2.2 Vérification

- Depuis un PC du LAN utilisant pfSense comme DNS, tester la résolution :

```cmd
nslookup interne.billu.lan
ping interne.billu.lan
```

- Résultat attendu :

```
Server:  pfsense.BillU.lan
Address: 10.0.2.1

Name:    interne.billu.lan
Address: 172.16.130.138
```

- Accéder au portail via le nom de domaine :

```
http://interne.billu.lan
```

---

# 3. Configuration GPO Active Directory

## 3.1 Création de la GPO

- Sur le Windows Server, ouvrir **Group Policy Management** (`gpmc.msc`)
- Clic droit sur l'OU des utilisateurs → **Create a GPO in this domain**
- Nommer la GPO : `User-Raccourci-site-int`

## 3.2 Configuration du raccourci

- Clic droit sur la GPO → **Edit**
- Naviguer vers :

```
User Configuration → Preferences → Windows Settings → Shortcuts
```

- Clic droit → **New → Shortcut** et renseigner les champs suivants :

|Champ|Valeur|
|---|---|
|Action|Create|
|Name|`Portail BillU`|
|Target type|URL|
|Location|**Desktop**|
|Target URL|`http://interne.billu.lan`|

- Cliquer **OK** pour valider.

## 3.3 Liaison de la GPO

- Dans **Group Policy Management**, clic droit sur la GPO → **Link to OU**
- Sélectionner l'OU contenant les utilisateurs du domaine
- Vérifier que la GPO est bien liée et activée

## 3.4 Vérification

- Sur un PC client, forcer l'application des GPO :

```cmd
gpupdate /force
```

- Vérifier que la GPO est bien appliquée :

```cmd
gpresult /r
```

- Résultat attendu dans la section **Objets Stratégie de groupe appliqués** :

```
User-Raccourci-site-int
```

- Déconnecter puis reconnecter la session utilisateur — le raccourci **Portail BillU** doit apparaître sur le bureau.
