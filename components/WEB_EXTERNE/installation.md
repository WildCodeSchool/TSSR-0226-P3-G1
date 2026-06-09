# Sommaire
- [**1. Création de la VM dans Proxmox**](#1-création-de-la-vm-dans-proxmox)
  - [**1.1 Paramètres de la VM**](#11-paramètres-de-la-vm)
  - [**1.2 Configuration réseau**](#12-configuration-réseau)
- [**2. Configuration post-installation**](#2-configuration-post-installation)
  - [**2.1 Mise à jour du système**](#21-mise-à-jour-du-système)
  - [**2.2 Changement du nom de la machine**](#22-changement-du-nom-de-la-machine)
  - [**2.3 Configuration réseau permanente**](#23-configuration-réseau-permanente)
- [**3. Installation d'Apache**](#3-installation-dapache)
  - [**3.1 Installation du paquet**](#31-installation-du-paquet)
  - [**3.2 Activation et démarrage**](#32-activation-et-démarrage)
  - [**3.3 Vérification**](#33-vérification)
- [**4. Déploiement du site**](#4-déploiement-du-site)
  - [**4.1 Copie du fichier**](#41-copie-du-fichier)
  - [**4.2 Permissions**](#42-permissions)
  - [**4.3 Vérification**](#43-vérification)

---

# 1. Création de la VM dans Proxmox

## 1.1 Paramètres de la VM

- Dans l'interface Proxmox, créer une nouvelle VM avec les paramètres suivants :

| Paramètre | Valeur |
|-----------|--------|
| Nom | BV-130-140 |
| OS | Debian 13 |
| CPU | 2 vCPU |
| RAM | 2 Go |
| Disque | 20 Go |

## 1.2 Configuration réseau

- Associer la carte réseau de la VM au bridge DMZ :

| Paramètre | Valeur |
|-----------|--------|
| Interface Proxmox | `vmbr105` |
| Réseau | DMZ — `10.0.3.0/24` |

---

# 2. Configuration post-installation

## 2.1 Mise à jour du système

- Une fois connecté en SSH ou sur la console, mettre à jour le système :

```bash
apt update && apt upgrade -y
```

## 2.2 Changement du nom de la machine

- Définir le hostname :

```bash
hostnamectl set-hostname BV-130-140
```

- Éditer `/etc/hosts` pour ajouter la résolution locale :

```bash
nano /etc/hosts
```

- Ajouter ou modifier la ligne suivante :

```
127.0.1.1    BV-130-140
```

## 2.3 Configuration réseau permanente

- Éditer le fichier `/etc/network/interfaces` :

```bash
nano /etc/network/interfaces
```

- Contenu du fichier :

```
auto ens18
iface ens18 inet static
    address 10.0.3.20
    netmask 255.255.255.0
    gateway 10.0.3.1
    dns-nameservers 10.0.3.1
    dns-search billu.lan
```

- Redémarrer le service réseau :

```bash
systemctl restart networking
```

- Vérifier la configuration :

```bash
ip a
ping -c 3 10.0.3.1
```

- Résultat attendu :

```
3 packets transmitted, 3 received, 0% packet loss
```

---

# 3. Installation d'Apache

## 3.1 Installation du paquet

- Installer Apache :

```bash
apt install apache2 -y
```

## 3.2 Activation et démarrage

- Activer Apache au démarrage et le lancer :

```bash
systemctl enable apache2
systemctl start apache2
```

## 3.3 Vérification

- Vérifier que le service est actif :

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

---

# 4. Déploiement du site

## 4.1 Copie du fichier

- Depuis votre poste, copier le fichier du site sur le serveur :

```bash
scp index.html root@10.0.3.20:/var/www/html/index.html
```

## 4.2 Permissions

- Appliquer les bonnes permissions sur le dossier web :

```bash
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/
```

## 4.3 Vérification

- Tester l'accès au site depuis le serveur :

```bash
curl -I http://localhost
```

- Résultat attendu :

```
HTTP/1.1 200 OK
Server: Apache/2.4.x (Debian)
```

- Depuis un poste du LAN, accéder à :

```
http://10.0.3.20
```

---
- Résultat attendu :

```
LISTEN 0  128  0.0.0.0:22  0.0.0.0:*  users:(("sshd",...))
```
