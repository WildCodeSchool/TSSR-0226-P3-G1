# Sommaire

- [**1. Vue d'ensemble**](#1-vue-densemble)
- [**2. Objectifs**](#2-objectifs)
- [**3. Architecture**](#3-architecture)
  - [**3.1 Serveur de sauvegarde Debian**](#31-serveur-de-sauvegarde-debian)
  - [**3.2 Configuration LVM**](#32-configuration-lvm)
  - [**3.3 Montage du partage Windows**](#33-montage-du-partage-windows)
- [**4. Structure de la documentation**](#4-structure-de-la-documentation)
- [**5. Références**](#5-références)

# 1. Vue d'ensemble

Ce document présente la mise en place du stockage LVM (Logical Volume Manager) sur le serveur de sauvegarde Debian de l'entreprise BillU. Le serveur permet d'assurer la sauvegarde automatisée des dossiers partagés du serveur Windows Server via une synchronisation planifiée avec rsync.

# 2. Objectifs

- **Mettre en place du stockage flexible** : Utiliser LVM pour gérer le volume de sauvegarde de manière évolutive
- **Sauvegarder les données partagées** : Copier automatiquement les dossiers `Departement` et `Services` du serveur Windows vers le serveur Debian
- **Automatiser la sauvegarde** : Planifier l'exécution du script rsync via cron tous les jours à 2h du matin
- **Séparer les données de la sauvegarde** : Stocker les sauvegardes sur un disque distinct du disque système
# 3. Architecture

## 3.1 Serveur de sauvegarde Debian

| Paramètre      | Valeur                 |
| -------------- | ---------------------- |
| Hostname       | BV-130-139             |
| OS             | Debian 13              |
| Disque système | /dev/sda — 15 Go       |
| Disque backup  | /dev/sdb — 50 Go (LVM) |
## 3.2 Configuration LVM

| Élément         | Nom       | Taille | Point de montage |
| --------------- | --------- | ------ | ---------------- |
| Physical Volume | /dev/sdb  | 50 Go  | —                |
| Volume Group    | VG_BACKUP | 50 Go  | —                |
| Logical Volume  | LV_BACKUP | 50 Go  | /mnt/backup      |
### 3.3 Montage du partage Windows

| Paramètre            | Valeur                  |
| -------------------- | ----------------------- |
| Serveur source       | BV-130-153.BillU.lan    |
| Partage              | Dossier_partage         |
| Point de montage     | /mnt/windows            |
| Protocole            | CIFS                    |
| Utilisateur          | Administrator           |
| Dossiers sauvegardés | Departement/, Services/ |
| Dossiers exclus      | Utilisateurs/           |
**Planification rsync :**

| Paramètre | Valeur                               |
| --------- | ------------------------------------ |
| Script    | /usr/local/bin/backup.sh             |
| Log       | /var/log/backup.log                  |
| Fréquence | Tous les jours à 2h00                |
| Cron      | `0 2 * * * /usr/local/bin/backup.sh` |
# 4. Structure de la documentation

- **README.md** : Ce fichier
- **[installation.md](installation.md)** : Fichier d'installation des logiciels
- **[configuration.md](configuration.md)** : Fichier de configuration des logiciels installés 

# 5. Références

- [https://wiki.debian.org/LVM](https://wiki.debian.org/LVM) — Documentation LVM sur Debian
- [https://man7.org/linux/man-pages/man8/lvm.8.html](https://man7.org/linux/man-pages/man8/lvm.8.html) — Manuel LVM
- [https://linux.die.net/man/1/rsync](https://linux.die.net/man/1/rsync) — Documentation rsync
- [https://wiki.samba.org/index.php/LinuxCIFS](https://wiki.samba.org/index.php/LinuxCIFS) — Montage CIFS sous Linux
