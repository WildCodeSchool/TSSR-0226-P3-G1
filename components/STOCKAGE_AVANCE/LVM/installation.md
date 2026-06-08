## Sommaire

- [**1. Prérequis**](#1-prérequis)
   - [**1.1 Configuration de la VM Proxmox**](#11-configuration-de-la-vm-proxmox)
- [**2. Configuration réseau**](#2-configuration-réseau)
   - [**2.1 Définir une adresse IP fixe**](#21-définir-une-adresse-ip-fixe)
   - [**2.2 Vérifier la configuration réseau**](#22-vérifier-la-configuration-réseau)
- [**3. Changement du nom d'hôte**](#3-changement-du-nom-dhôte)
   - [**3.1 Modifier le hostname**](#31-modifier-le-hostname)
   - [**3.2 Modifier le fichier hosts**](#32-modifier-le-fichier-hosts)
   - [**3.3 Vérifier le hostname**](#33-vérifier-le-hostname)
- [**4. Ajout du disque de sauvegarde**](#4-ajout-du-disque-de-sauvegarde)
   - [**4.1 Ajout du disque dans Proxmox**](#41-ajout-du-disque-dans-proxmox)
   - [**4.2 Vérifier la détection du disque**](#42-vérifier-la-détection-du-disque)
- [**5. Installation des paquets nécessaires**](#5-installation-des-paquets-nécessaires)

---

# 1. Prérequis

## 1.1 Configuration de la VM Proxmox

| Paramètre       | Valeur             |
|-----------------|--------------------|
| Type            | VM (pas CT)        |
| OS              | Debian             |
| Hostname        | BV-130-139         |
| Réseau          | vmbr104            |
| Adresse IP      | 172.16.130.239/17  |
| Disque système  | sda — 15 Go        |
| Disque backup   | sdb — 50 Go        |

---

# 2. Configuration réseau

## 2.1 Définir une adresse IP fixe

- Éditer le fichier de configuration réseau :

```bash
nano /etc/network/interfaces
```

- Modifier la configuration de l'interface (ici `ens18`) :

```
auto ens18
iface ens18 inet static
    address 172.16.130.239
    netmask 255.255.128.0
    gateway 172.16.128.1
```

- Redémarrer le service réseau pour appliquer :

```bash
systemctl restart networking
```

## 2.2 Vérifier la configuration réseau

- Vérifier l'adresse IP :

```bash
ip a
```

- Vérifier la passerelle :

```bash
ip route
```

- Vérifier le DNS :

```bash
cat /etc/resolv.conf
```

- Tester la connectivité :

```bash
ping 8.8.8.8
```

---

# 3. Changement du nom d'hôte

## 3.1 Modifier le hostname

```bash
hostnamectl set-hostname BV-130-139
```

## 3.2 Modifier le fichier hosts

- Éditer `/etc/hosts` :

```bash
nano /etc/hosts
```

- Ajouter ou modifier la ligne suivante :

```
172.16.130.239    BV-130-139
```

## 3.3 Vérifier le hostname

```bash
hostnamectl
```

- Résultat attendu :

```
Static hostname: BV-130-139
```

---

# 4. Ajout du disque de sauvegarde

## 4.1 Ajout du disque dans Proxmox

- Dans l'interface Proxmox :
   - Sélectionner la VM `BV-130-139`
   - Cliquer sur `Hardware`
   - Cliquer sur `Add` > `Hard Disk`
   - Choisir le stockage approprié
   - Définir la taille à `50Go`
   - Cliquer sur `Add`

## 4.2 Vérifier la détection du disque

- Vérifier que le disque est bien reconnu par le système :

```bash
lsblk
```

- Résultat attendu :

```
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda      8:0    0   15G  0 disk
├─sda1   8:1    0 14.2G  0 part /
├─sda2   8:2    0    1K  0 part
└─sda5   8:5    0  842M  0 part [SWAP]
sdb      8:16   0   50G  0 disk
```

---

# 5. Installation des paquets nécessaires

- Mettre à jour les paquets :

```bash
apt update && apt upgrade -y
```

- Installer les paquets requis :

```bash
apt install lvm2 cifs-utils rsync -y
```

- Vérifier les installations :

```bash
lvm version
rsync --version
```
