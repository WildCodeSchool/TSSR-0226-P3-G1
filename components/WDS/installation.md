# Installation — Serveur de déploiement WDS + MDT

---

## 1. Configuration de base de Windows Server

1. **Renommer** le serveur (`BV-130-121`).
2. Définir une **IP fixe** (`172.16.130.121`), avec le **DNS pointant sur le DC** (`172.16.130.253`).
3. **Joindre le domaine** `BillU.lan`.
4. Redémarrer.

**Piège rencontré** : pour configurer WDS en mode _AD-intégré_, il faut être connecté avec un **compte du domaine** ayant les droits admin (ex. `BILLU\Administrateur`), **pas** le compte administrateur **local**. Sinon l'assistant échoue avec « The user name or password is incorrect ». Vérifier avec `whoami` (doit afficher `billu\...` et non `bv-130-121\...`).

---

## 2. Installation du rôle WDS

### Via l'interface graphique

1. **Gestionnaire de serveur** → _Gérer_ → _Ajouter des rôles et fonctionnalités_.
2. Installation basée sur un rôle → sélectionner le serveur.
3. Cocher **Services de déploiement Windows** → _Ajouter les fonctionnalités_.
4. Conserver les deux services de rôle : **Serveur de déploiement** + **Serveur de transport**.
5. Installer.

### Configuration initiale de WDS

1. _Outils_ → **Services de déploiement Windows**.
2. Clic droit sur le serveur → **Configurer le serveur**.
3. **Intégré à Active Directory**.
4. Dossier d'installation à distance : `C:\RemoteInstall` (accepter l'avertissement sur le volume système).
5. Paramètres PXE : **« Répondre à tous les ordinateurs clients (connus et inconnus) »**, sans approbation administrateur.
6. **Ne PAS ajouter d'image de démarrage** à cette étape.


---

## 3. Installation de l'ADK + WinPE + MDT

### Versions à utiliser (2026)

|Composant|Version|Remarque|
|---|---|---|
|Windows ADK|**24H2 (10.1.26100)**|La 22H2 a été retirée du site Microsoft ; la 26H1 (10.1.28000) a le support des pilotes WinPE cassé → **à éviter**|
|WinPE add-on|**24H2** (même version)|Installeur **séparé** — indispensable, WinPE n'est plus inclus dans l'ADK|
|MDT|**8456** (dernier build)|Retiré des canaux Microsoft (voir ci-dessous)|

### Ordre d'installation (strict)

1. **Windows ADK 24H2** — page : `learn.microsoft.com/windows-hardware/get-started/adk-install`
    - Il suffit de cocher **Deployment Tools**.
2. **WinPE add-on 24H2** — installeur séparé, même page.
3. **MDT 8456** — fichier `MicrosoftDeploymentToolkit_x64.msi`.

### Récupération de MDT 8456

Le `.msi` ayant été retiré des canaux officiels Microsoft :

- Source de secours : miroir communautaire `github.com/loannvnrr/MDT-8456`.
- **Vérifier l'authenticité** : taille ≈ **20,6 Mo** (un fichier ~11 Ko est un faux/stub), et signature **Microsoft Corporation** (clic droit → Propriétés → Signatures numériques).
- **Vérifier la version après install** :

```powershell
$dll = "C:\Program Files\Microsoft Deployment Toolkit\Templates\Distribution\Tools\x64\Microsoft.BDD.Utility.dll"
(Get-Item $dll).VersionInfo | Format-List FileVersion, ProductVersion
```

 Doit afficher **`6.3.8456.1000`**. Si `6.3.8450.1000`, c'est l'ancien build → désinstaller et réinstaller le bon `.msi`.

---

## 4. Correctifs post-installation

### Correctif obligatoire — dossier x86 factice

L'ADK récent n'a plus de WinPE 32 bits, mais MDT le cherche et plante à la génération du boot image. Créer un faux dossier x86 :

```powershell
$winpe = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment"
Copy-Item "$winpe\amd64" "$winpe\x86" -Recurse -Force
```

---

## 5. Récapitulatif de l'état attendu

À la fin de l'installation :

- WDS installé et configuré (flèche verte « démarré » dans la console), **sans image**.
- ADK 24H2 + WinPE 24H2 + MDT 8456 installés.
- Dossier `x86` factice créé.
- MDT en version `6.3.8456.1000`.
