# Sommaire

- [**1. Vue d'ensemble**](#1-vue-densemble)
- [**2. Objectifs**](#2-objectifs)
- [**3. Architecture**](#3-architecture)
- [**4. Structure de la documentation**](#4-structure-de-la-documentation)

# 1. Vue d'ensemble

Le **serveur DHCP** est le serveur qui va distribuer les ip de tout le reseau interne de **BillU**. Positionné dans le VLAN 30 (Server), ce poste permet aux administrateurs systèmes et réseau de parametrer l'ensemble des plages ip et passerelles par defaut de l'infrastructure.

## Caractéristiques principales

- **OS** : ``Windows Server 2025``
- **VLAN** : ``130 - Serveur``
- **Adresse IP** : ``172.16.130.117/24``
- **Domaine** : ``Billu.lan``
- **Fonction** : ``Serveur de Mise à Jour Windows`` 

# 2. Objectifs

Ce serveur permet : 

- **Centralisation** : Point d'accès unique pour la gestion des MAJ Windows
- **Mise à jour** : Permet le deploiement des MaJ Windows sur les Serveurs et postes clients Windows de l'infrastructure.
## Périmètre d'administration


## Spécifications matérielles
| Composant            | Spécification               |
| -------------------- | --------------------------- |
| **Type**             | Machine virtuelle (Proxmox) |
| **CPU**              | 6 vCPU                      |
| **RAM**              | 14 Go                       |
| **Disque**           | 200 Go                      |
| **Interface réseau** |  vmbr104                    |
## Configuration réseau
| Paramètre          | Valeur          |
| ------------------ | --------------- |
| **Nom de machine** | BV-130-117      |
| **VLAN**           | 130 - Serveur   |
| **Adresse IP**     | 172.16.10.117   |
| **Masque**         | 255.255.128.0   |
| **Passerelle**     | 172.16.128.1    |
| **DNS primaire**   | 172.16.130.253  |
| **Domaine**        | Billu.lan       |
# 4. Structure de la documentation

- **README.md** : Ce fichier
- **[installation.md](installation.md)** : Fichier d'installation des logiciels
