# Sommaire
- [**1. Configuration Apache**](#1-configuration-apache)
  - [**1.1 Vérification du service**](#11-vérification-du-service)
  - [**1.2 Configuration du VirtualHost**](#12-configuration-du-virtualhost)
  - [**1.3 Vérification de la syntaxe**](#13-vérification-de-la-syntaxe)
  - [**1.4 Déploiement du site**](#14-déploiement-du-site)
- [**2. Configuration pfSense**](#2-configuration-pfsense)
  - [**2.1 NAT Port Forward**](#21-nat-port-forward)
  - [**2.2 Règle Firewall WAN**](#22-règle-firewall-wan)
  - [**2.3 Règles DMZ**](#23-règles-dmz)
  - [**2.4 NAT Reflection**](#24-nat-reflection)
- [**3. Configuration DNS interne**](#3-configuration-dns-interne)
  - [**3.1 Ajout de l'enregistrement**](#31-ajout-de-lenregistrement)
  - [**3.2 Vérification**](#32-vérification)

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
    ServerName www.billu.lan

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

## 1.4 Déploiement du site

- Copier le fichier du site depuis votre poste :

```bash
scp index.html root@10.0.3.20:/var/www/html/index.html
```

- Appliquer les bonnes permissions :

```bash
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/
```

- Vérifier que le site est accessible depuis le serveur :

```bash
curl -I http://localhost
```

- Résultat attendu :

```
HTTP/1.1 200 OK
Server: Apache/2.4.x (Debian)
```

---

# 2. Configuration pfSense

## 2.1 NAT Port Forward

- Aller dans **Firewall → NAT → Port Forward → Add** et renseigner les champs suivants :

| Champ | Valeur |
|-------|--------|
| Interface | WAN |
| Protocol | TCP |
| Destination | WAN address |
| Destination port | 80 (HTTP) |
| Redirect target IP | `10.0.3.20` |
| Redirect target port | 80 (HTTP) |
| Description | NAT HTTP to webserveur DMZ |
| Filter rule association | Add associated filter rule |

- Cliquer **Save** puis **Apply Changes**.

## 2.2 Règle Firewall WAN

- Vérifier dans **Firewall → Rules → WAN** que la règle associée au NAT est bien présente :

| Champ | Valeur |
|-------|--------|
| Action |  Pass |
| Interface | WAN |
| Protocol | TCP |
| Destination | `10.0.3.20` |
| Destination port | 80 (HTTP) |
| Description | NAT HTTP to webserveur DMZ |

## 2.3 Règles DMZ

- Vérifier dans **Firewall → Rules → DMZ** que les règles sont dans cet ordre :

| Ordre | Action | Source | Destination | Port | Description |
|-------|--------|--------|-------------|------|-------------|
| 1 | Block | DMZ subnets | RFC1918 | * | Deny All DMZ → LAN |
| 2 | Pass | DMZ subnets | This Firewall | 53 | Allow DNS for DMZ |
| 3 | Pass | DMZ subnets | * | * | Allow DMZ → Web |

La règle **Deny All DMZ → LAN** doit impérativement être en **première position** pour empêcher tout rebond depuis la DMZ vers le réseau interne en cas de compromission du serveur web.

## 2.4 NAT Reflection

Pour que les PCs du LAN puissent accéder au site via l'IP WAN `192.168.1.2` (simulation d'un accès internet) :

- Aller dans **System → Advanced → Firewall & NAT**
- Trouver la section **Network Address Translation**
- Modifier le paramètre **NAT Reflection mode for port forwards** :

| Paramètre | Valeur |
|-----------|--------|
| NAT Reflection mode for port forwards | **Pure NAT** |

- Cliquer **Save** puis **Apply Changes**.

- Tester depuis un PC LAN en accédant à :

```
http://192.168.1.2
```

---

# 3. Configuration DNS interne

## 3.1 Ajout de l'enregistrement

Pour accéder au site via un nom de domaine depuis le LAN :

- Aller dans **Services → DNS Resolver → Host Overrides → Add**

| Champ | Valeur |
|-------|--------|
| Host | `www` |
| Domain | `billu.lan` |
| IP | `192.168.1.2` |
| Description | Site web externe BillU |

- Cliquer **Save** puis **Apply Changes**.

## 3.2 Vérification

- Depuis un PC du LAN utilisant pfSense comme DNS, tester la résolution :

```cmd
nslookup www.billu.lan
ping www.billu.lan
```

- Résultat attendu :

```
Server:  pfsense.BillU.lan
Address: 10.0.2.1

Name:    www.billu.lan
Address: 192.168.1.2
```

- Accéder au site via le nom de domaine :

```
http://www.billu.lan
```
