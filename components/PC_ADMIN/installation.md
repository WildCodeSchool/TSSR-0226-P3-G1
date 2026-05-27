# Sommaire
- [**1. Prérequis**](#1-prérequis)
- [**2. Installation des outils Windows**](#2-installation-des-outils-windows)
  - [**2.1 Installation RSAT**](#21-installation-rsat)
  - [**2.2 Installation RDP**](#22-installation-rdp)
  - [**2.3 Installation Remote PowerShell**](#23-installation-remote-powershell)
  - [**2.4 Installation Suite Sysinternal**](#24-installation-suite-sysinternal)
- [**3. Installation des outils Linux**](#3-installation-des-outils-linux)
  - [**3.1 Installation MobaXterm**](#31-installation-mobaxterm)
  - [**3.2 Installation GitBash**](#32-installation-gitbash)
  - [**3.3 Installation WinSCP**](#33-installation-winscp)
  - [**3.4 Installation FileZilla**](#34-installation-filezilla)
  - [**3.5 Installation WSL**](#35-installation-wsl)
  - [**3.6 Installation VNC**](#36-installation-vnc)
  - [**3.7 Installation Putty**](#37-installation-putty)
  - [**3.8 Installation Termius**](#38-installation-termius)
- [**4. Installation des outils multi-OS**](#4-installation-des-outils-multi-os)
  - [**4.1 Wireshark**](#41-wireshark)
  - [**4.2 Trippy**](#42-trippy)
  - [**4.3 OpenSSH**](#43-openssh)
# 1. Prérequis 

## Caractéristiques requises

### Matériel

- **Type** : VM Proxmox
- **Ram** : 8 GO
- **CPU** : 4 
- **Disque dur** : 40 GO
- **Carte réseau** : 1 interface réseau **VMBR100**

### OS 

- Windows 11 Pro

### Accès réseau 

- Accès au réseau VLAN Admin (140)
- Connectivité vers tous les VLANS de l'infrastructure 
- Accès Internet pour télécharger les outils

# 2. Installation des outils Windows

## 2.1 Installation RSAT 

**RSAT** (Remote Server Administration Tools) est intégré a Windows, pas besoin de télécharger quoi que ce soit.

**Via Paramètres** : 

- ``Paramètres`` > ``Applications`` > ``Fonctionnalités facultatives``
- Cliquer sur ``Afficher les fonctionnalités``
- Puis sur ``Afficher les fonctionnalités disponible``
- Dans la barre de recherche taper **RSAT**
- Cocher les éléments suivant :
  - ``RSAT: Outils Active Directory Domain Services Directory et Services LDS`` 
  - ``RSAT: Outils du serveur DHCP``
  - ``RSAT: Outils du serveurs DNS``
  - ``RSAT: Outils de gestion de l'accès à distance``
  - ``RSAT: Gestionnaire du serveur``
  - ``RSAT: Outils de gestion de stratégie de groupe``
- Cliquer sur **Installer** pour chaque fonctionnalité sélectionnée

## 2.2 Installation RDP

Le **RDP** (Remote Desktop Protocol) est aussi intégré a Windows. Il permet de se **connecter vers d'autres machines** (client) et **accepter les connexions entrantes** (serveur).

**Activer le client RDP** :

- ``Win+R``
- ``mstsc.exe`` 
- Ou rechercher ``Connexion Bureau à Distance`` dans le menu Démarrer

**Activer le serveur RDP** :

- ``Paramètres`` > ``Système`` > ``Bureau à distance``
- Activer le bouton ``Activer le Bureau à distance``

Pour la sécurité, il est préférable d'autoriser **certains utilisateurs** à se connecter en **RDP** , et de changer le port par défaut (3389) pour limiter les scans automatiques

## 2.3 Installation Remote PowerShell

**Remote PowerShell** est directement intégré a Windows. Il permet d'exécuter des commandes PowerShell directement sur des serveurs distants sans **RDP**. 

**Dans PowerShell en admin** : 

**Activer le service WinRM** 

```powershell
Enable-PSRemoting -Force
```

**Vérifier que le statut est Running**

```powershell
Get-Service WinRM
```

## 2.4 Installation Suite Sysinternal

La **Suite Sysinternal** est une collection d'outils Microsoft pour analyser, diagnostiquer et administrer Windows en profondeur

**Télécharger la suite complète**

- Aller sur https://learn.microsoft.com/fr-fr/sysinternals/downloads/sysinternals-suite
- Télécharger ``SysinternalsSuite.zip``
- Créer le dossier Sysinternals dans ``C:\Program Files\Sysinternals`` 
- Extraire le fichier zip directement dans le dossier

Choisir ensuite les outils suivants et les mettre en raccourci : 

- ``procexp.exe`` , ``autoruns.exe`` , ``tcpview.exe`` , ``bginfo.exe`` 

# 3. Installation des outils Linux

## 3.1 Installation MobaXterm

Logiciel multi usage qui permet de faire du **SSH , SCP , SFTP , X11** 

**Installation**

- Aller sur https://mobaxterm.mobatek.net/download.html
- Télécharger la version ``Home Edition`` > ``Insaller Edition``
- Lancer l'installateur

## 3.2 Installation GitBash

Terminal Bash léger sans MobaXterm

**Installation**

- Aller sur https://git-scm.com/download/win
- Télécharger l'installateur
- Lancer l'installateur

## 3.3 Installation WinSCP

WinSCP est un logiciel qui permet, par exemple, de transférer des fichiers entre un PC et des serveurs Linux via SFTP/SCP. Interface graphique simple.

**Installation** 

- Aller sur https://winscp.net/eng/download.php
- Télécharger ``WinSCP Installation Package``
- Lancer l'installateur
- Pour le mode d'interface , choisir entre : 
  - **Commander** : double panneau (gauche = local, droite = serveur)
  - **Explorer** : style explorateur Windows

## 3.4 Installation FileZilla

Alternative à WinSCP, un peu plus connu, supporte **FTP/SFTP/FTPS**.

**Installation**

- Aller sur https://filezilla-project.org/download.php
- Télécharger ``FileZilla Client`` 
- Lancer l'installateur

## 3.5 Installation WSL

**WSL** est une vraie distribution Linux qui tourne directement sur Windows. Très utile pour lancer des commandes bash, scripts, outils Linux directement depuis le PC Admin

**Installation via PowerShell en administrateur**

```powershell
  wsl --install
```

## 3.6 Installation VNC

Le logiciel **VNC** permet de prendre la main à distance sur l'interface graphique d'un serveur Linux. 

**Installation**

- Aller sur https://www.realvnc.com/fr/connect/download/viewer/
- Télécharger ``VNC Viewer pour Windows``
- Lancer l'installateur 

## 3.7 Installation Putty

Logiciel qui permet de se connecter en **SSH** aux serveur Linux.

**Installation** 

- Aller sur https://www.putty.org
- Télécharger ``putty-64bits-0.84-installer.msi``
- Lancer l'installateur

## 3.8 Installation Termius

Logiciel qui permet de se connecter en **SSH** aux serveur Linux.

**Installation**

- Aller sur https://termius.com
- Télécharger la version Windows
- Lancer l'installateur

# 4. Installation des outils multi-OS

## 4.1 Wireshark

**Wireshark** permet de capturer et analyser tout le trafic réseau qui passe par la machine.

**Installation**

- Aller sur https://www.wireshark.org/download.html
- Télécharger ``Windows x64 Installer``
- Lancer l'installateur
- Accepter l'installation de ``Npcap`` 

## 4.2 Trippy

**Trippy** est un outil de diagnostic réseau qui combien **traceroute** et **ping** en temps réel dans une interface terminal claire et lisible.

**Installation de scoop** 

- Scoop est un gestionnaire de paquet sur Windows, un peu comme **apt** pour Linux
- Dans PowerShell en admin : 

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex
```

**Installation Trippy**

  ``` powershell
  scoop install trippy
  ```

## 4.3 OpenSSH

**OpenSSH** est un outil intégré à Windows, il suffit de l'activer.

**Installation**

- Dans PowerShell en admin :

```powershell
Add-WindowsCapability -Online -Name OpenSSH.Client
Add-WindowsCapability -Online -Name OpenSSH.Server
Start-Service sshd
Set-Service -Name sshd -StartupType Automatic
```

