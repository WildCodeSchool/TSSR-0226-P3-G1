# Sommaire

- [**1. Création de la VM dans Proxmox**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#1-cr%C3%A9ation-de-la-vm-dans-proxmox)
    - [**1.1 Paramètres de la VM**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#11-param%C3%A8tres-de-la-vm)
    - [**1.2 Configuration réseau**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#12-configuration-r%C3%A9seau)
- [**2. Configuration post-installation**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#2-configuration-post-installation)
    - [**2.1 Mise à jour du système**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#21-mise-%C3%A0-jour-du-syst%C3%A8me)
    - [**2.2 Changement du nom de la machine**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#22-changement-du-nom-de-la-machine)
    - [**2.3 Configuration réseau permanente**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#23-configuration-r%C3%A9seau-permanente)
- [**3. Installation d'Apache**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#3-installation-dapache)
    - [**3.1 Installation du paquet**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#31-installation-du-paquet)
    - [**3.2 Activation et démarrage**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#32-activation-et-d%C3%A9marrage)
    - [**3.3 Vérification**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#33-v%C3%A9rification)
- [**4. Déploiement du portail**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#4-d%C3%A9ploiement-du-portail)
    - [**4.1 Copie du fichier**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#41-copie-du-fichier)
    - [**4.2 Permissions**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#42-permissions)
    - [**4.3 Vérification**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#43-v%C3%A9rification)

---

# 1. Création de la VM dans Proxmox

## 1.1 Paramètres de la VM

- Dans l'interface Proxmox, créer une nouvelle VM avec les paramètres suivants :

| Paramètre | Valeur     |
| --------- | ---------- |
| Nom       | BV-130-138 |
| OS        | Debian 13  |
| CPU       | 2 vCPU     |
| RAM       | 2 Go       |
| Disque    | 20 Go      |

## 1.2 Configuration réseau

- Associer la carte réseau de la VM au bridge LAN :

|Paramètre|Valeur|
|---|---|
|Interface Proxmox|`vmbr104`|
|Réseau|LAN — `172.16.0.0/17`|

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
hostnamectl set-hostname BV-130-138
```

- Éditer `/etc/hosts` pour ajouter la résolution locale :

```bash
nano /etc/hosts
```

- Ajouter ou modifier la ligne suivante :

```
127.0.1.1    BV-130-138
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
    address 172.16.130.138
    netmask 255.255.128.0
    gateway 172.16.128.1
    dns-nameservers 172.16.130.253
    dns-search billu.lan
```

- Redémarrer le service réseau :

```bash
systemctl restart networking
```

- Vérifier la configuration :

```bash
ip a
ping -c 3 172.16.0.1
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

# 4. Déploiement du portail

## 4.1 Copie du fichier

- Depuis votre poste, copier le fichier du portail sur le serveur :

```bash
scp interne.html root@172.16.130.138:/var/www/html/index.html
```

## 4.2 Permissions

- Appliquer les bonnes permissions sur le dossier web :

```bash
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/
```

## 4.3 Vérification

- Tester l'accès au portail depuis le serveur :

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
http://172.16.130.138
```


