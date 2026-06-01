
# Sommaire

- [**1. Vue d'ensemble**](#1-vue-densemble)
- [**2. Objectifs**](#2-objectifs)
- [**3. Architecture**](#3-architecture)
- [**4. Structure de la documentation**](#4-structure-de-la-documentation)
- [**5. Fonctionnalités et logiciels installés**](#5-fonctionnalités-et-logiciels-installés)

# 1. Vue d'ensemble
Le **Serveur AD-DS Windows-Core** est le serveur qui va se rattacher au serveur domaine **BillU.lan** existant. Il va donc le rejoindre en tant que **DC** (Domain Controller).

## Caractéristiques principales

- **OS** : ``Windows-Server-2022-CORE``
- **VLAN** : ``130 - Serveur``
- **Adresse IP** : ``172.16.10.252``
- **Domaine** : ``Billu.lan``
- **Fonction** : ``Administration centralisée de l'infrastructure et du catalogue `` 

# 2. Objectifs

Le serveur AD-DS supplémentaire renforce l'infrastructure existante sur plusieurs axes :

- Haute disponibilité : En cas de défaillance du DC principal, ce serveur prend le relais et assure la continuité des authentifications
- Répartition de charge : Les requêtes d'authentification sont distribuées entre les deux DC
- Réplication : Les objets AD (utilisateurs, groupes, GPO) sont répliqués automatiquement entre les deux contrôleurs
- Sécurité : Aucun point de défaillance unique sur l'infrastructure d'authentification

**Périmètre d'administration**

- Forêt : BillU.lan
- Rôle : Domain Controller supplémentaire (GC - Global Catalog)

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
| **Nom de machine** | BV-140-104        |
| **VLAN**           | 130 - Serveur     |
| **Adresse IP**     | 172.16.10.252 |
| **Masque**         | 255.255.255.0   |
| **Passerelle**     | 172.16.10.254   |
| **DNS primaire**   | 172.16.10.253   |
| **Domaine**        | Billu.lan       |
# 4. Structure de la documentation

- **README.md** : Ce fichier
- **[installation.md](installation.md)** : Fichier d'installation des logiciels
- **[configuration.md](configuration.md)** : Fichier de configuration des logiciels installés 

# 5. Fonctionnalités et logiciels installés 

**Automatisation par script PowerShell**

L'installation et la promotion du serveur en DC supplémentaire sont entièrement automatisées via deux fichiers :
- ``config.json``
- ``Install-ADDS.ps1``

**Fonctionnement du script**

Le script effectue les opérations suivantes dans l'ordre :

- Lecture du fichier de configuration config.json passé en argument
- Vérification des droits administrateur locaux
- Renommage du serveur si le nom actuel diffère de celui défini dans la config
- Configuration réseau : IP statique, passerelle, DNS pointant vers le DC principal
- Test de connectivité vers le DC principal (5 tentatives avec délai)
- Installation du rôle AD DS via Install-WindowsFeature
- Promotion en DC supplémentaire via Install-ADDSDomainController
- Redémarrage automatique pour finaliser la promotion
