

# 1. Vue d'ensemble

Ce document présente la mise en place du serveur **WSUS** (Windows Server Update Services) de l'entreprise **BillU**. WSUS centralise la récupération des mises à jour Microsoft depuis internet, puis les distribue de manière contrôlée aux postes clients, aux serveurs et aux contrôleurs de domaine du réseau interne.

Le serveur est intégré à l'Active Directory existant (`BillU.lan`). L'affectation des machines aux groupes de mise à jour est pilotée par stratégie de groupe (GPO) liée aux unités d'organisation (OU), ce qui permet d'appliquer un comportement de mise à jour différent selon le type de machine.

# 2. Objectifs

- **Centraliser les mises à jour** : Récupérer une seule fois les mises à jour Microsoft sur le serveur WSUS plutôt que de laisser chaque machine les télécharger sur internet.
- **Maîtriser le déploiement** : Approuver manuellement les mises à jour avant leur distribution, afin de les valider sur un groupe avant de les généraliser.
- **Lier WSUS à l'Active Directory** : Affecter automatiquement chaque machine au bon groupe WSUS via une GPO appliquée à son OU.
- **Différencier les comportements** : Appliquer une politique de mise à jour adaptée aux clients, aux serveurs et aux contrôleurs de domaine, du plus automatique au plus prudent.

# 3. Architecture

## 3.1 Serveur WSUS

Le serveur WSUS est installé sur une machine virtuelle dédiée, membre du domaine `BillU.lan`.

### Spécifications matérielles

|Composant|Spécification|
|---|---|
|**Type**|Machine virtuelle|
|**Disque système**|Disque 0 — 200 Go (C:)|
|**Disque stockage**|Disque 1 — 100 Go (O:)|
|**Rôle**|Windows Server Update Services|

### Configuration réseau

|Paramètre|Valeur|
|---|---|
|**Nom de machine**|BV-130-117|
|**FQDN**|BV-130-117.BillU.lan|
|**Adresse IP**|172.16.130.117 (fixe)|
|**Masque**|255.255.128.0|
|**Passerelle**|172.16.128.1|
|**DNS primaire**|172.16.130.253|
|**Domaine**|BillU.lan|
|**Port WSUS**|8530 (HTTP)|

Les fichiers de mises à jour sont stockés sur le disque dédié `O:\WSUS` afin de ne pas saturer le disque système. La base de données utilise l'instance interne **WID** (Windows Internal Database), suffisante pour cet usage et sans dépendance à un SQL Server séparé.

## 3.2 Liaison avec l'Active Directory

L'affectation des machines aux groupes WSUS se fait par **ciblage côté client** (_client-side targeting_) : c'est la GPO appliquée à chaque OU qui indique à la machine dans quel groupe WSUS elle doit se ranger.

```
Active Directory (BillU.lan)
│
├── OU Postes_Utilisateurs ──── GPO "WSUS - Clients" ──── Groupe WSUS : Clients
│
├── OU Windows_serveurs ─────── GPO "WSUS - Serveurs" ─── Groupe WSUS : Serveurs
│   (BU_Computers\Serveurs)
│
└── OU Domain Controllers ───── GPO "WSUS - DC" ───────── Groupe WSUS : DC
```

> Le réglage **Options → Computers → « Use Group Policy or registry settings on computers »** doit être activé côté WSUS pour que le serveur prenne en compte le groupe envoyé par les GPO. Sans lui, toutes les machines restent dans _Unassigned Computers_.

## 3.3 Gestion différenciée des mises à jour

Le comportement de mise à jour est défini par le paramètre **Configure Automatic Updates** de chaque GPO, du plus automatique (clients) au plus prudent (contrôleurs de domaine).

|Type|OU source|Groupe WSUS|Option Automatic Updates|Comportement|
|---|---|---|---|---|
|**Clients**|Postes_Utilisateurs|Clients|4 — Auto download and schedule install|Téléchargement + installation automatiques, redémarrage planifié|
|**Serveurs**|Windows_serveurs|Serveurs|3 — Auto download and notify install|Téléchargement automatique, installation validée par l'admin|
|**DC**|Domain Controllers|DC|2 — Notify download and notify install|Aucune action sans validation, patch manuel un par un|

# 4. Structure de la documentation

- **README.md** : Ce fichier
- **[INSTALLATION.md](installation.md)** : Préparation de la VM, installation du rôle WSUS et configuration initiale (source, produits, classifications, synchronisation)
- **[CONFIGURATION.md](configuration.md)** : Groupes WSUS, GPO de ciblage par OU, comportement différencié, approbations et vérifications

# 5. Références

- [https://learn.microsoft.com/windows-server/administration/windows-server-update-services/get-started/windows-server-update-services-wsus](https://learn.microsoft.com/windows-server/administration/windows-server-update-services/get-started/windows-server-update-services-wsus) — Documentation officielle WSUS
- [https://learn.microsoft.com/windows/deployment/update/waas-wu-settings](https://learn.microsoft.com/windows/deployment/update/waas-wu-settings) — Paramètres GPO Windows Update
- [https://learn.microsoft.com/windows-server/administration/windows-server-update-services/deploy/4-configure-group-policy-settings-for-automatic-updates](https://learn.microsoft.com/windows-server/administration/windows-server-update-services/deploy/4-configure-group-policy-settings-for-automatic-updates) — Configuration des GPO pour les mises à jour automatiques
