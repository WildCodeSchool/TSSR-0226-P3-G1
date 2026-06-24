# Déploiement de masse Windows 11 — WDS + MDT

Mise en place d'un serveur de déploiement permettant d'installer Windows 11 de façon **complètement automatisée** sur des machines vierges, via le boot réseau (PXE), avec **jonction automatique au domaine Active Directory**.

---

## 1. Objectif du projet

Déployer un système d'exploitation **Windows 11** sur une machine vierge, complètement automatisé :

| Mode                        | Description                                  | Intervention de l'opérateur        |
| --------------------------- | -------------------------------------------- | ---------------------------------- |
| **Complètement automatisé** | PXE + déploiement de A à Z sans intervention | Aucune                             |

La solution retenue est **WDS** (Windows Deployment Services) couplé à **MDT** (Microsoft Deployment Toolkit), installés sur une **VM dédiée** sous Proxmox.

---

## 2. Architecture

```
        Réseau SERVEURS (172.16.128.0/17, vmbr104)
        ┌──────────────────────────────────────┐
        │  srv-wds  (172.16.130.121)            │
        │   - Windows Server 2022              │
        │   - Rôle WDS (PXE/TFTP)              │
        │   - ADK + WinPE + MDT                │
        │   - Partage de déploiement (E:\)     │
        │                                      │
        │  DC / DHCP / DNS (172.16.130.253)    │
        └──────────────────┬───────────────────┘
                           │  Routeur + IP Helper
        ┌──────────────────┴───────────────────┐
        │   Réseau CLIENTS (172.16.0.0/17, vmbr103)
        │   Machines vierges → boot PXE → master │
        └────────────────────────────────────────┘
```

- **WDS** sert le boot réseau (PXE) et le **boot image MDT** (`LiteTouchPE_x64.wim`).
- **MDT** gère la séquence de tâches : partitionnement, application de l'image Windows 11, configuration, jonction au domaine.
- Serveurs et clients étant sur **deux sous-réseaux** séparés par des routeurs, un **IP Helper** relaie les requêtes PXE vers le serveur WDS.

---

## 3. Environnement

|Élément|Valeur|
|---|---|
|Hyperviseur|Proxmox VE|
|Serveur de déploiement|`BV-130-121.BillU.lan` — `172.16.130.121`|
|Domaine AD|`BillU.lan` (NetBIOS : `BILLU`)|
|DHCP / DNS|`172.16.130.253`|
|Réseau serveurs|`172.16.128.0/17` (bridge `vmbr104`)|
|Réseau clients|`172.16.0.0/17` (bridge `vmbr103`)|
|OS serveur|Windows Server 2022|
|OS déployé|Windows 11 (x64, FR)|
|Partage MDT|`\\BV-130-121\DeploymentShare` → `E:\DeploymentShare`|

---

## 4. Documentation

- **[installation.md](installation.md)** — Mise en place du serveur (VM, Windows Server, WDS, ADK, MDT).
- **[configuration.md](configuration.md)** — Configuration MDT, les 3 modes, jonction au domaine, import dans WDS, réseau PXE et dépannage.

---

## 5. Avertissement de sécurité

Les fichiers `CustomSettings.ini` et `Bootstrap.ini` contiennent des identifiants **en clair** (compte de connexion au partage et compte de jonction au domaine). Bonnes pratiques :

- Utiliser un **compte de service dédié** aux droits minimaux (lecture du partage + jonction de machines au domaine), jamais un administrateur complet.
- Restreindre l'accès en lecture à ces fichiers sur le partage.
- Changer les mots de passe après la phase de tests.
