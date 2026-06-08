# Sommaire

- [**1. Vue d'ensemble**](#1-vue-densemble)
- [**2. Objectifs**](#2-objectifs)
- [**3. Architecture*](#3-architecture)
  - [**3.1 Serveur Windows Server**](#31-serveur-windows-server)
  - [**3.2 Configuration RAID1**](#32-configuration-raid1)
- [**4. Structure de la documentation**](#4-structure-de-la-documentation)
- [**5. Références**](#5-références)

---

# 1. Vue d'ensemble

Ce document présente la mise en place du RAID1 (mirroring) sur le serveur Windows Server de l'entreprise BillU. Le RAID1 permet d'assurer la redondance des données en dupliquant en temps réel le contenu d'un disque sur un second disque identique. En cas de panne d'un des deux disques, les données restent intégralement accessibles sur le disque survivant.

---

# 2. Objectifs

- **Assurer la redondance des données** : Dupliquer automatiquement les données sur deux disques physiques distincts
- **Garantir la disponibilité** : En cas de panne d'un disque, le système continue de fonctionner sans perte de données
- **Séparer les données du système** : Le volume RAID est sur un disque DATA distinct du disque système

---

# 3. Architecture

## 3.1 Serveur Windows Server

| Paramètre       | Valeur               |
|-----------------|----------------------|
| Hostname        | BV-130-153           |
| OS              | Windows Server       |
| Réseau          | vmbr104              |
| Adresse IP      | 172.16.130.250       |
| Disque système  | C: — disque OS       |
| Disque RAID     | K: — 30 Go x2        |

## 3.2 Configuration RAID1

| Paramètre        | Valeur               |
|------------------|----------------------|
| Type de RAID     | RAID1 — Mirroring    |
| Nombre de disques| 2                    |
| Taille par disque| 30 Go                |
| Lettre de lecteur| K:                   |
| Outil utilisé    | Gestionnaire de disques Windows |

---

# 4. Structure de la documentation

- **README.md** : Ce fichier
- **[installation.md](installation.md)** : Fichier d'installation des logiciels
- **[configuration.md](configuration.md)** : Fichier de configuration des logiciels installés 

---

# 5. Références

- https://learn.microsoft.com/fr-fr/windows-server/storage/storage-spaces/storage-spaces-direct-overview — Stockage Windows Server
- https://learn.microsoft.com/fr-fr/windows-server/storage/disk-management/overview-of-disk-management — Gestionnaire de disques
