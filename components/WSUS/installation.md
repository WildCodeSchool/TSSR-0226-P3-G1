
---

# 1. Prérequis

- Active Directory `BillU.lan` fonctionnel
- Une VM dédiée sous **Windows Server 2022**, avec un disque système et un second disque de stockage (≥ 100 Go)
- Accès administrateur sur la VM
- Connexion internet (synchronisation depuis Microsoft Update)

---

# 2. Préparation de la VM

## 2.1 Disque de stockage dédié

Le second disque accueille les fichiers de mises à jour, afin de ne pas saturer le disque système.

1. Ouvrir **Gestion des disques** (clic droit sur le menu Démarrer → _Gestion des disques_, ou `diskmgmt.msc`)
2. Si le disque est neuf, l'initialiser (clic droit sur le disque → _Initialiser le disque_), puis créer un **nouveau volume simple**
3. Le formater en **NTFS** et lui attribuer la lettre **O:** (volume `stockage_MAJ`)

|Disque|Capacité|Lettre|Système de fichiers|Usage|
|---|---|---|---|---|
|**Disque 0**|200 Go|C:|NTFS|Système|
|**Disque 1**|100 Go|O:|NTFS|Stockage des MAJ|

 Le dossier `O:\WSUS` sera créé automatiquement lors de la post-installation, inutile de le créer à la main.

## 2.2 Adresse IP fixe

Un serveur WSUS doit disposer d'une adresse IP fixe et d'un DNS pointant vers le contrôleur de domaine.

1. **Panneau de configuration → Réseau et Internet → Connexions réseau**
2. Clic droit sur la carte → **Propriétés** → _Protocole Internet version 4 (TCP/IPv4)_ → **Propriétés**
3. Saisir une configuration fixe :

|Paramètre|Valeur|
|---|---|
|**IPv4**|172.16.130.117|
|**Masque**|255.255.128.0|
|**Passerelle**|172.16.128.1|
|**DNS**|172.16.130.253|
|**DHCP**|Désactivé|

La configuration peut être vérifiée dans une invite de commandes avec `ipconfig /all` (le suffixe DNS principal doit afficher `BillU.lan`).

## 2.3 Jonction au domaine

1. Ouvrir les **Propriétés système** (clic droit sur _Ce PC_ → _Propriétés_ → _Modifier les paramètres_ → onglet _Nom de l'ordinateur_ → **Modifier…**)
2. Cocher **Domaine** et saisir `BillU.lan`
3. Fournir les identifiants d'un compte autorisé à joindre le domaine
4. Redémarrer la machine

Après redémarrage, l'onglet _Nom de l'ordinateur_ doit indiquer le nom complet `BV-130-117.BillU.lan`.

---

# 3. Installation du rôle WSUS

## 3.1 Lancement de l'assistant d'ajout de rôles

1. Ouvrir le **Gestionnaire de serveur** (Server Manager)
2. Menu **Gérer** (Manage) → **Ajouter des rôles et fonctionnalités** (Add Roles and Features)
3. Type d'installation : **Installation basée sur un rôle ou une fonctionnalité**
4. Serveur de destination : sélectionner le serveur local (**BV-130-117**)

## 3.2 Sélection du rôle et des services

1. À l'écran **Rôles de serveurs**, cocher **Windows Server Update Services**
2. Dans la fenêtre qui s'ouvre, cliquer **Ajouter des fonctionnalités** (Add Features) pour accepter les outils requis (IIS, etc.)
3. Poursuivre jusqu'à l'écran **Services de rôle** (Role Services) et laisser les choix par défaut :

| Service de rôle         | Sélection | Rôle                                    |
| ----------------------- | --------- | --------------------------------------- |
| **WID Connectivity**    | ✅         | Base de données interne (WID)           |
| **WSUS Services**       | ✅         | Service WSUS                            |
| SQL Server Connectivity | ❌         | À cocher uniquement si SQL Server dédié |

## 3.3 Emplacement du contenu sur O:

1. À l'écran **Content** (Emplacement du contenu), cocher **Store updates in the following location** (Stocker les mises à jour à l'emplacement suivant)
2. Saisir le chemin du disque dédié :

```
O:\WSUS
```

3. Cliquer **Suivant**, puis **Installer**

 C'est cet écran qui dirige les fichiers de mises à jour vers le disque dédié plutôt que sur le disque système.

## 3.4 Tâches de post-installation

1. Une fois l'installation terminée, un **drapeau de notification** apparaît en haut du Gestionnaire de serveur
2. Cliquer dessus → **Lancer les tâches de post-installation** (Launch Post-Installation tasks)
3. Attendre le statut **Complete** (Terminé)

L'assistant **Windows Server Update Services Configuration Wizard** se lance ensuite automatiquement.

---

# 4. Configuration initiale (assistant)

## 4.1 Serveur amont et proxy

|Écran|Réglage|
|---|---|
|**Microsoft Update Improvement Program**|Décoché|
|**Choose Upstream Server**|_Synchronize from Microsoft Update_ (pas de WSUS parent)|
|**Specify Proxy Server**|Aucun proxy (champs vides)|
|**Choose Languages**|_Start Connecting_, puis sélectionner uniquement English (+ French si besoin)|

## 4.2 Choix des produits

Ne sélectionner que les systèmes réellement présents dans le parc, sans les variantes _Drivers_ ni _Upgrade_.

|Produit à cocher|Correspond à|
|---|---|
|**Windows 11**|Postes clients|
|**Windows 10**|Postes clients (si applicable)|
|**Microsoft Server operating system-21H2**|Windows Server 2022 (serveurs + DC)|


À éviter : les lignes contenant _Servicing Drivers_, _Upgrade & Servicing Drivers_, _Dynamic Update_, ainsi que les anciens systèmes non présents (Windows 7, 8, Server 20xx).

## 4.3 Choix des classifications

|Classification|Sélection|Justification|
|---|---|---|
|**Critical Updates**|✅|Correctifs critiques|
|**Security Updates**|✅|Cœur de la démarche sécurité|
|**Update Rollups**|✅|Cumuls de correctifs|
|**Updates**|✅|Mises à jour générales|
|**Definition Updates**|(option)|Définitions Defender (si produit Defender coché)|
|**Drivers**|❌|Surcharge la base et le stockage|
|**Feature Packs / Service Packs / Upgrades**|❌|Volumineux, inutiles en lab|

## 4.4 Planification de la synchronisation

|Écran|Réglage|
|---|---|
|**Configure Sync Schedule**|_Synchronize automatically_, 1 fois par jour|
|**Finished**|Cocher _Begin initial synchronization_|

La synchronisation initiale récupère les métadonnées des mises à jour (≈ 1967 mises à jour pour les produits sélectionnés). Elle peut durer de quelques minutes à plus d'une heure selon le débit. Tant qu'elle est en cours, certains réglages (dont _Options → Computers_) restent verrouillés.

La configuration des groupes et des GPO se poursuit dans **[CONFIGURATION.md](https://claude.ai/chat/CONFIGURATION.md)**.
