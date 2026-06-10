# Serveur Web Interne – BillU

# Sommaire

- [**1. Vue d'ensemble**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#1-vue-densemble)
- [**2. Objectifs**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#2-objectifs)
- [**3. Architecture**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#3-architecture)
    - [**3.1 Serveur web Debian**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#31-serveur-web-debian)
    - [**3.2 Configuration réseau LAN**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#32-configuration-r%C3%A9seau-lan)
    - [**3.3 Configuration pfSense**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#33-configuration-pfsense)
- [**4. Structure de la documentation**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#4-structure-de-la-documentation)
- [**5. Références**](https://claude.ai/chat/6c9ced3c-0832-4e44-9e84-3cdfeceafb02#5-r%C3%A9f%C3%A9rences)

# 1. Vue d'ensemble

Ce document présente la mise en place du serveur web interne de l'entreprise BillU. Le serveur héberge le portail intranet destiné aux collaborateurs, accessible uniquement depuis le réseau LAN de l'entreprise. Il propose un accès rapide aux applications internes (GLPI, messagerie, planning), les actualités internes et les informations RH.

# 2. Objectifs

- **Centraliser l'accès aux applications internes** : Proposer un portail unique donnant accès à GLPI, la messagerie, le planning et les autres outils métier
- **Restreindre l'accès au LAN** : Le site interne ne doit pas être accessible depuis l'extérieur, uniquement depuis le réseau `172.16.0.0/17`
- **Faciliter la navigation des collaborateurs** : Déployer un raccourci bureau via GPO sur tous les postes utilisateurs
- **Fournir les actualités internes** : Diffuser les news de l'entreprise par département

# 3. Architecture

## 3.1 Serveur web Debian

| Paramètre        | Valeur         |
| ---------------- | -------------- |
| Hostname         | BV-130-138     |
| OS               | Debian 13      |
| Adresse IP       | 172.16.130.138 |
| Serveur web      | Apache 2.4     |
| Racine web       | /var/www/html/ |
| Interface réseau | vmbr104 (LAN)  |

## 3.2 Configuration réseau LAN

|Paramètre|Valeur|
|---|---|
|Réseau LAN|172.16.0.0/17|
|Passerelle|172.16.0.1 (pfSense)|
|Serveur web interne|172.16.130.138|
|Interface Proxmox|vmbr104|

```
Collaborateurs LAN (172.16.x.x)
          │
          ▼
    pfSense LAN (10.0.2.1)
          │
          ▼
Serveur Web Interne Apache (172.16.130.138)
```

## 3.3 Configuration pfSense

|Interface|Adresse|Rôle|
|---|---|---|
|WAN|192.168.1.2|Accès internet|
|LAN|10.0.2.1|Réseau interne entreprise|
|DMZ|10.0.3.1|Zone démilitarisée|

**Accès au portail interne :**

|Réseau|URL|
|---|---|
|LAN (direct)|http://172.16.130.138|
|LAN (DNS)|http://interne.billu.lan|

**GPO Active Directory :**

|Paramètre|Valeur|
|---|---|
|Nom GPO|User-Raccourci-site-int|
|Type|Shortcut — URL|
|Target URL|http://interne.billu.lan|
|Location|Desktop|
|Scope|Tous les utilisateurs du domaine|

# 4. Structure de la documentation

- **README-interne.md** : Ce fichier
- **[INSTALLATION-interne.md](https://claude.ai/chat/INSTALLATION-interne.md)** : Création de la VM, installation de Debian et Apache, déploiement du portail
- **[CONFIGURATION-interne.md](https://claude.ai/chat/CONFIGURATION-interne.md)** : Configuration Apache, DNS interne et GPO Active Directory

# 5. Références

- [https://httpd.apache.org/docs/](https://httpd.apache.org/docs/) — Documentation officielle Apache
- [https://github.com/apache/httpd](https://github.com/apache/httpd) — Sources Apache sur GitHub
- [https://glpi-project.org/](https://glpi-project.org/) — Documentation GLPI
- [https://wiki.debian.org/NetworkConfiguration](https://wiki.debian.org/NetworkConfiguration) — Configuration réseau Debian
- [https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/gpupdate](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/gpupdate) — Documentation GPO Microsoft
