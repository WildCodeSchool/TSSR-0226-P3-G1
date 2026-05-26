# Sommaire

- [**1. Vue d'ensemble**](#1-vue-densemble)
- [**2. Objectifs**](#2-objectifs)
- [**3. Architecture**](#3-architecture)
- [**4. Structure de la documentation**](#4-structure-de-la-documentation)
- [**5. Fonctionnalités et logiciels installés**](#5-fonctionnalités-et-logiciels-installés)
  - [**5.1 Administration des serveurs Windows**](#51-administration-des-serveurs-windows)
  - [**5.2 Administration des serveurs Linux**](#52-administration-des-serveurs-linux)
  - [**5.3 Logiciels et outils multi-OS**](#53-logiciels-et-outils-multi-os)
- [**6. Références**](#6-références)

# 1. Vue d'ensemble

Le **PC-ADMIN** est le poste de travail d'administration centralisé de l'infrastructure **BillU**. Positionné dans le VLAN 140 (Admin), ce poste permet aux administrateurs systèmes et réseau d'accéder à l'ensemble des équipements et services de l'infrastructure.

## Caractéristiques principales

- **OS** : ``Windows 11 Pro``
- **VLAN** : ``140 - Admin``
- **Adresse IP** : ``172.16.10.20/24``
- **Domaine** : ``Billu.lan``
- **Fonction** : ``Administration centralisée de l'infrastructure`` 

# 2. Objectifs

Ce PC d'administration permet : 

- **Centralisation** : Point d'accès unique pour l'administration de tous les équipements
- **Sécurité** : Isolation dans un VLAN dédié aux admins

## Périmètre d'administration

- **Serveur Windows** : AD DS, DNS, DHCP via outils **RSAT**
- **Équipements réseau** : VyOS, pfSense via **SSH/HTTP** 

# 3. Architecture 

## Spécifications matérielles
| Composant            | Spécification               |
| -------------------- | --------------------------- |
| **Type**             | Machine virtuelle (Proxmox) |
| **CPU**              | 4 vCPU                      |
| **RAM**              | 8 Go                        |
| **Disque**           | 40 Go                       |
| **Interface réseau** |  vmbr100                    |
## Configuration réseau
| Paramètre          | Valeur          |
| ------------------ | --------------- |
| **Nom de machine** | PC-ADMIN        |
| **VLAN**           | 140 - Admin     |
| **Adresse IP**     | 172.16.10.20/24 |
| **Masque**         | 255.255.255.0   |
| **Passerelle**     | 172.16.10.254   |
| **DNS primaire**   | 172.16.10.253   |
| **Domaine**        | Billu.lan       |
# 4. Structure de la documentation

- **README.md** : Ce fichier
- **[installation.md](components/PC_ADMIN/installation.md)** : Fichier d'installation des logiciels
- **[configuration.md](components/PC_ADMIN/configuration.md)** : Fichier de configuration des logiciels installés 

# 5. Fonctionnalités et logiciels installés 

## 5.1 Administration des serveurs Windows

- **Outils RSAT**
  - Gestion des utilisateurs / groupes
  - Gestion des ordinateurs
  - Gestion des OU 
  - Gestion général de l'AD 
  - DNS
  - DHCP

- **Windows RDP**
  - Prise de main à distance

- **Remote PowerShell**
  - CLI à distance

- **Suite logiciels Sysinternal**
  - Outils de gestion général des serveurs/machines

## 5.2 Administration des serveurs Linux

- **GitBash / MobaXterm** 
  - Shell bash 
  - SSH et SCP

- **Putty / Termius** 
  - Connexion SSH

- **FileZilla / WinSCP** 
  - Transfert de fichiers via FTP

- **WSL** 
  - Intégration de Linux dans Windows

- **VNC**
  - Prise en main à distance en GUI

## 5.3 Logiciels et outils multi-OS

- **Trippy**
  - Outil de diagnostique réseau

- **OpenSSH**
  - Serveur et client SSH

- **Wireshark** 
  - Analyse réseau

# 6. Références 

#### Microsoft
- [Documentation RSAT](https://learn.microsoft.com/fr-fr/windows-server/remote/remote-server-administration-tools)
- [OpenSSH pour Windows](https://learn.microsoft.com/fr-fr/windows-server/administration/openssh/openssh_install_firstuse)
- [PowerShell Documentation](https://learn.microsoft.com/fr-fr/powershell/)
- [Active Directory](https://learn.microsoft.com/fr-fr/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview)

#### Outils tiers
- [Wireshark Documentation](https://www.wireshark.org/docs/)
- [MobaXterm](https://mobaxterm.mobatek.net/documentation.html)
- [Putty Documentation](https://documentation.help/PuTTY/)
- [WinSCP Documentation](https://winscp.net/eng/docs/start)
- [Sysinternals Suite](https://learn.microsoft.com/fr-fr/sysinternals/)
- [Trippy GitHub](https://github.com/fujiapple852/trippy)
