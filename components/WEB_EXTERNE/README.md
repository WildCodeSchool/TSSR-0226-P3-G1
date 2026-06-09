# Sommaire
- [**1. Vue d'ensemble**](#1-vue-densemble)
- [**2. Objectifs**](#2-objectifs)
- [**3. Architecture**](#3-architecture)
  - [**3.1 Serveur web Debian**](#31-serveur-web-debian)
  - [**3.2 Configuration réseau DMZ**](#32-configuration-réseau-dmz)
  - [**3.3 Configuration pfSense**](#33-configuration-pfsense)
- [**4. Structure de la documentation**](#4-structure-de-la-documentation)
- [**5. Références**](#5-références)

# 1. Vue d'ensemble

Ce document présente la mise en place du serveur web externe de l'entreprise BillU. Le serveur héberge le site vitrine public de l'entreprise, accessible depuis internet. Il est déployé dans une zone démilitarisée (DMZ) isolée du réseau interne, protégée par pfSense qui assure le filtrage et la redirection du trafic entrant.

# 2. Objectifs

- **Exposer le site vitrine BillU** : Rendre le site public accessible depuis internet via un NAT port forward sur pfSense
- **Isoler le serveur web** : Héberger le serveur dans une DMZ séparée du LAN pour limiter l'exposition en cas de compromission
- **Bloquer les accès retour** : Empêcher tout trafic depuis la DMZ vers le réseau interne via les règles pfSense
- **Fournir un contenu complet** : Proposer un site vitrine avec portail, organigramme, actualités et formulaire de contact

# 3. Architecture

## 3.1 Serveur web Debian

| Paramètre | Valeur |
|-----------|--------|
| Hostname | BV-130-140 |
| OS | Debian 13 |
| Adresse IP | 10.0.3.20 |
| Serveur web | Apache 2.4 |
| Racine web | /var/www/html/ |
| Interface réseau | vmbr105 (DMZ) |

## 3.2 Configuration réseau DMZ

| Paramètre | Valeur |
|-----------|--------|
| Réseau DMZ | 10.0.3.0/24 |
| Passerelle DMZ | 10.0.3.1 (pfSense) |
| Serveur web | 10.0.3.20 |
| Interface Proxmox | vmbr105 |

```
Internet
    │
    ▼
Box FAI (192.168.1.1)
    │
    ▼
pfSense WAN (192.168.1.2)  ←── NAT Port Forward 80 → 10.0.3.20
    │
    ▼
DMZ (10.0.3.0/24)
    │
    ▼
Serveur Web Apache (10.0.3.20)
```

## 3.3 Configuration pfSense

| Interface | Adresse | Rôle |
|-----------|---------|------|
| WAN | 192.168.1.2 | Accès internet / NAT entrant |
| LAN | 10.0.2.1 | Réseau interne entreprise |
| DMZ | 10.0.3.1 | Zone démilitarisée |

**NAT Port Forward :**

| Paramètre | Valeur |
|-----------|--------|
| Interface | WAN |
| Protocol | TCP |
| Destination | WAN address |
| Port entrant | 80 (HTTP) |
| Redirect IP | 10.0.3.20 |
| Redirect port | 80 (HTTP) |

**Règles DMZ :**

| Action | Source | Destination | Port | Description |
|--------|--------|-------------|------|-------------|
| Block | DMZ subnets | RFC1918 | * | Deny All DMZ → LAN |
| Pass | DMZ subnets | This Firewall | 53 | Allow DNS |
| Pass | DMZ subnets | * | * | Allow DMZ → Web |

# 4. Structure de la documentation

- **README.md** : Ce fichier
- **[INSTALLATION.md](INSTALLATION.md)** : Création de la VM, installation de Debian et Apache, déploiement du site
- **[CONFIGURATION.md](CONFIGURATION.md)** : Configuration Apache, pfSense (NAT, firewall, NAT reflection) et DNS interne

# 5. Références

- [https://httpd.apache.org/docs/](https://httpd.apache.org/docs/) — Documentation officielle Apache
- [https://github.com/apache/httpd](https://github.com/apache/httpd) — Sources Apache sur GitHub
- [https://docs.netgate.com/pfsense/](https://docs.netgate.com/pfsense/) — Documentation pfSense
- [https://wiki.debian.org/NetworkConfiguration](https://wiki.debian.org/NetworkConfiguration) — Configuration réseau Debian
- [https://www.proxmox.com/en/proxmox-ve](https://www.proxmox.com/en/proxmox-ve) — Documentation Proxmox VE
