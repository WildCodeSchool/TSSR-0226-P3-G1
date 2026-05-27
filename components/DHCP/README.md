# Sommaire

- [**1. Vue d'ensemble**](#1-vue-densemble)
- [**2. Objectifs**](#2-objectifs)
- [**3. Architecture**](#3-architecture)
- [**4. Structure de la documentation**](#4-structure-de-la-documentation)

# 1. Vue d'ensemble

Le **serveur DHCP** est le serveur qui va distribuer les ip de tout le reseau interne de **BillU**. Positionné dans le VLAN 30 (Server), ce poste permet aux administrateurs systèmes et réseau de parametrer l'ensemble des plages ip et passerelles par defaut de l'infrastructure.

## Caractéristiques principales

- **OS** : ``Windows Server 2022``
- **VLAN** : ``130 - Serveur``
- **Adresse IP** : ``172.16.10.253/24``
- **Domaine** : ``Billu.lan``
- **Fonction** : ``Configuration et distribution des ip du reseau interne`` 

# 2. Objectifs

Ce serveur permet : 

- **Centralisation** : Point d'accès unique pour la gestion des bails ip
- **Distribution** : Distribue une configuration reseau pour tout les pc qu'il gere avec entre autre la passerelle par defaut
## Périmètre d'administration

- **VLAN utilisateur** : Distribue une plage ip de 172.16.10.25 à 172.16.10.50 aux differents terminaux utilisateurs

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
| **VLAN**           | 130 - Admin     |
| **Adresse IP**     | 172.16.10.253 |
| **Masque**         | 255.255.255.0   |
| **Passerelle**     | 172.16.10.254   |
| **DNS primaire**   | 172.16.10.253   |
| **Domaine**        | Billu.lan       |
# 4. Structure de la documentation

- **README.md** : Ce fichier
- **[Install.md](DHCP/Install.md)** : Fichier d'installation des logiciels


