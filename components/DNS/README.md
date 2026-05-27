# Sommaire

- [**1. Vue d'ensemble**](#1-vue-densemble)
- [**2. Objectifs**](#2-objectifs)
- [**3. Architecture**](#3-architecture)
- [**4. Structure de la documentation**](#4-structure-de-la-documentation)


# 1. Vue d'ensemble

Le **Serveur DNS** est le serveur de nom de **BillU**. Positionné dans le VLAN 130 (Serveur), ce poste permet aux administrateurs systèmes et réseau de parametrer et de gerer la resolution des noms de l'infrastructure.

## Caractéristiques principales

- **OS** : ``Windows serveur 2022``
- **VLAN** : ``130 - Serveur``
- **Adresse IP** : ``172.16.10.253``
- **Domaine** : ``Billu.lan``
- **Fonction** : ``Résolution de noms`` 

# 2. Objectifs

Ce PC d'administration permet : 

- **Resolution des noms** : sert de base à la resolution de nom en ip pour de nombreux services comme l'AD par exemple

## Périmètre d'administration

- L'administration est deléguée aux seuls admins sytemes et reseau habilités

# 3. Architecture 

## Spécifications matérielles
| Composant            | Spécification               |
| -------------------- | --------------------------- |
| **Type**             | Machine virtuelle (Proxmox) |
| **CPU**              | 2 vCPU                      |
| **RAM**              | 4 Go                        |
| **Disque**           | 32 Go                       |
| **Interface réseau** |  vmbr100                    |
## Configuration réseau
| Paramètre          | Valeur          |
| ------------------ | --------------- |
| **Nom de machine** | BV-100-101       |
| **VLAN**           | 130 - Serveur     |
| **Adresse IP**     | 172.16.10.253 |
| **Masque**         | 255.255.255.0   |
| **Passerelle**     | 172.16.10.254   |
| **DNS primaire**   | 172.16.10.253   |
| **Domaine**        | Billu.lan       |
# 4. Structure de la documentation

- **README.md** : Ce fichier
- **[installation.md](installation.md)** : Fichier d'installation des logiciels
- **[configuration.md](configuration.md)** : Fichier de configuration des logiciels installés 


