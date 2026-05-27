
# Sommaire

- [**1. Vue d'ensemble**](#1-vue-densemble)
- [**2. Objectifs**](#2-objectifs)
- [**3. Architecture**](#3-architecture)
- [**4. Structure de la documentation**](#4-structure-de-la-documentation)
- [**5. Fonctionnalités et logiciels installés**](#5-fonctionnalités-et-logiciels-installés)


Le **Serveur AD-DS** est leserveur qui va gerer toute l'infrastructure objet de notre fôret **BillU.lan**. Positionné dans le VLAN 130 (Serveur), ce serveur a travers son architecture va permettre de definir les regles de sécurité des differents groupes d'utilisateurs et d'ordinateurs de notre domaine.

## Caractéristiques principales

- **OS** : ``Windows Serveur 2022``
- **VLAN** : ``130 - Serveur``
- **Adresse IP** : ``172.16.10.253``
- **Domaine** : ``Billu.lan``
- **Fonction** : ``Administration centralisée de l'infrastructure et du catalogue `` 

# 2. Objectifs

Le serveur AD-DS va permettre la gestion de notre architecture

- **Centralisation** : Point d'accès unique pour l'administration de tous groupes d'utilisateurs et d'ordianteurs
- **Sécurité** : Parametrage fin de la sécurité grace aux differentes gpo

## Périmètre d'administration

- **Foret: BillU.lan**

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
| **Nom de machine** | PC-ADMIN        |
| **VLAN**           | 140 - Admin     |
| **Adresse IP**     | 172.16.10.253 |
| **Masque**         | 255.255.255.0   |
| **Passerelle**     | 172.16.10.254   |
| **DNS primaire**   | 172.16.10.253   |
| **Domaine**        | Billu.lan       |
# 4. Structure de la documentation

- **README.md** : Ce fichier
- **[installation.md](/components/PC_ADMIN/installation.md)** : Fichier d'installation des logiciels
- **[configuration.md](/components/PC_ADMIN/configuration.md)** : Fichier de configuration des logiciels installés 

# 5. Fonctionnalités et logiciels installés 

## Utilisation et configuration de serveur avec HelloMyDir :

Afin de ne pas laisser les regles par defaut lors de la création de notre fôret nous avons preferé faire le choix de parametrer notre fôret grace aux scripts **HelloMyDir**.
Il nous a permis de renforcer notre domaine grâce à des regles de securités par defaut plus exigentes que celles existantes.

#### Exemple: PSO
Un exemple avec les PSO suivantes sur les mp ou sur les comptes admin

