
# Sommaire

- [**1. Vue d'ensemble**](#1-vue-densemble)
- [**2. Objectifs**](#2-objectifs)
- [**3. Architecture**](#3-architecture)
  - [**3.1 Pare-Feu pfSense**](#31-pare-feu-pfsense)
  - [**3.2 Interface réseau**](#32-interface-réseau)
- [**4. Structure de la documentation**](#4-structure-de-la-documentation)
- [**5. Références**](#5-références)
# 1. Vue d'ensemble

Ce document présente en globalité la configuration du pare-feu **pfSense** de l'entreprise **BillU**.
Le pare-feu permet d'assurer la sécurité du réseau en filtrant le trafic entre Internet (*Wan*) , le réseau internet (*LAN*) et la zone démilitarisée (*DMZ*) qui héberge les serveurs publics (*web,mail etc..*

# 2. Objectifs

- **Sécuriser le périmètre réseau :** Protéger le réseau interne de **BillU** contre les accès non autorisés depuis Internet
- **Isoler la DMZ :** Empêcher tout accès direct entre la DMZ et le réseau interne tout en permettant la connexion depuis l'extérieur sur les serveurs de la DMZ

# 3. Architecture

## 3.1 Pare-Feu pfSense

- **Hostname :** Firewall
- **Domaine :** BillU.lan
- **Fuseau horaire :** Europe/Paris
- **Mot de passe admin :** Azerty1*

## 3.2 Interface réseau

| Interface | Adresse IP    | Masque | Description               |
| --------- | ------------- | ------ | ------------------------- |
| **WAN**   | 192.168.1.2   | /24    | Connexion Internet        |
| **LAN**   | 172.16.10.254 | /24    | Liaison vers routeur core |
| **DMZ**   | à définir     | x      | Zone démilitarisée        |
- **Gateway WAN** : 192.168.1.1
- **Gateway LAN (ROUTEUR CORE)** : à définir

# 4. Structure de la documentation

- **README.md** : Ce fichier
- **[installation.md](installation.md)** : Fichier d'installation complète de pfSense
- **[configuration.md](configuration.md)** : Fichier de configuration des logiciels installés
- **[supervision.md](supervision.md)** : Paramétrage de la supervision

# 5. Références

- [https://www.pfsense.org/](https://www.pfsense.org/) - Site officiel de pfSense
- [https://docs.netgate.com/pfsense/en/latest/](https://docs.netgate.com/pfsense/en/latest/) - Documentation officielle
- [https://docs.netgate.com/pfsense/en/latest/recipes/example-basic-configuration.html](https://docs.netgate.com/pfsense/en/latest/recipes/example-basic-configuration.html) - Configuration basique
- [https://docs.netgate.com/pfsense/en/latest/nat/port-forwards.html](https://docs.netgate.com/pfsense/en/latest/nat/port-forwards.html) - Configuration NAT
- [https://docs.netgate.com/pfsense/en/latest/firewall/index.html](https://docs.netgate.com/pfsense/en/latest/firewall/index.html) - Règles de pare-feu

