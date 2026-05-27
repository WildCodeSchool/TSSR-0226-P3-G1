# Sommaire

- [**1. Vue d'ensemble**](#1-vue-densemble)
- [**2. Objectifs**](#2-objectifs)
- [**3. Architecture**](#3-architecture)
- [**4. Structure de la documentation**](#4-structure-de-la-documentation)
- [**5. Services installés**](#5-services-installés)
- [**6. Références**](#6-références)

# 1. Vue d'ensemble

Ce document présente l'installation et la configuration complète de GLPI (Gestionnaire Libre de Parc Informatique) pour l'entreprise BillU.
GLPI est une solution open source de gestion des services informatiques.

GLPI permet : 

- La gestion centralisée de l'inventaire du parc informatique
- La gestion des tickets 
- La gestion des changements et projets (ITIL)
- La gestion des actifs et contrats
- Les rapports et statistoires
- L'intégration avec l'Active Directory pour l'authentification

# 2. Objectifs

- Centraliser la gestion du parc informatique
- Optimiser le support aux utilisateurs
- Améliorer la traçabilité et l'historique
- Réduire les coûts et anticiper les besoins
- Respecter les bonnes pratiques ITIL
- Faciliter la collaboration entre les équipes
- Produire des indicateurs et des rapports

# 3. Architecture 

## Spécifications matérielles

| Composant            | Spécification               |
| -------------------- | --------------------------- |
| **Type**             | Machine virtuelle (Proxmox) |
| **CPU**              | 1 vCPU                      |
| **RAM**              | 1 Go                        |
| **Disque**           | 15 Go                       |
| **Interface réseau** | vmbr100                     |
## Configuration réseau

| Paramètre          | Valeur        |
| ------------------ | ------------- |
| **Nom de machine** | BV-130-145    |
| **VLAN**           | 130 - GLPI    |
| **Adresse IP**     | 172.16.10.251 |
| **Masque**         | 255.255.255.0 |
| **Passerelle**     | 172.16.10.254 |
| **DNS primaire**   | 172.16.10.253 |
| **Domaine**        | Billu.lan     |
# 4. Structure de la documentation

- **README.md** : Ce fichier
- **[installation.md](installation.md)** : Fichier d'installation des logiciels
- **[configuration.md](configuration.md)** : Fichier de configuration des logiciels installés 

# 5. Services installés

**Services système** 

- **MariaDB** : Base de données relationnelle pour GLPI
- **Apache2** : Serveur web pour l'interface GLPI
- **PHP** : Moteur d'exécution de l'application GLPI
- **PHP-LDAP** : Module pour l'authentification Active Directory

**Base de données**

- **Base** : glpidb
- **Utilisateur** : glpiuser

# 6. Références

- https://glpi-project.org/ - Site officiel de GLPI
- https://glpi-install.readthedocs.io/ - Documentation d'installation
- https://github.com/glpi-project/glpi - Dépôt GitHub officiel
