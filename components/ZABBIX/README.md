# Sommaire

- [**1. Vue d'ensemble**](#1-vue-densemble)
- [**2. Objectifs**](#2-objectifs)
- [**3. Architecture**](#3-architecture)
- [**4. Structure de la documentation**](#4-structure-de-la-documentation)


# 1. Vue d'ensemble

Le **PC ZABBIX** est le PC qui gère la supervision du réseau **BillU**. Positionné dans le VLAN 140 (Admin), ce poste permet aux administrateurs systèmes et réseau de superviser le réseau

## Caractéristiques principales

- **OS** : ``Ubuntu 24.04``
- **VLAN** : ``140 - Admin``
- **Adresse IP** : ``172.16.10.253``
- **Domaine** : ``Billu.lan``
- **Fonction** : ``Supervision réseau`` 

# 2. Objectifs

Ce PC d'administration permet : 

- **La supervision du réseau** : permet d'avoir une vue générale du réseau, de son état et des problèmes eventuels.
- **La supervision du parefeu** : Permet une vue détaillé des principaux evenements et alertes
## Périmètre d'administration

- L'administration est deléguée aux seuls admins sytemes et reseau habilités

# 3. Architecture 

## Spécifications matérielles
| Composant            | Spécification               |
| -------------------- | --------------------------- |
| **Type**             | Machine virtuelle (Proxmox) |
| **CPU**              | 2 vCPU                      |
| **RAM**              | 4 Go                        |
| **Disque**           | 70 Go                       |
| **Interface réseau** |  vmbr103                    |
## Configuration réseau
| Paramètre          | Valeur          |
| ------------------ | --------------- |
| **Nom de machine** | PC-ZABBIX       |
| **VLAN**           | 140 - Admin    |
| **Adresse IP**     | 172.16.17.17 |
| **Masque**         | 255.255.255.0   |
| **Passerelle**     | 172.16.127.254   |
| **DNS primaire**   | 172.16.10.253   |
| **Domaine**        | Billu.lan       |
# 4. Structure de la documentation

- **README.md** : Ce fichier
- **[installation.md](installation.md)** : Fichier d'installation des logiciels
- **[configuration.md](configuration.md)** : Fichier de configuration des logiciels installés 
