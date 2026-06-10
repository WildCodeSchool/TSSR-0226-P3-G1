# Sommaire

- [**1. Présentation**](#1-présentation)
- [**2. Architecture Active Directory**](#2-architecture-active-directory)
- [**3. Convention de nommage et règles de tri**](#3-convention-de-nommage-et-règles-de-tri)
- [**4. Fonctionnement du script Move-ComputersToOU.ps1**](#4-fonctionnement-du-script-move-computertoou-ps1)
- [**5. Automatisation par tâche planifiée**](#5-automatisation-par-tâche-planifiée)
- [**6. Corbeille Active Directory**](#6-corbeille-active-directory)
- [**7. Procédure d'installation**](#7-procédure-d-installation)
- [**8. Procédure de test**](#8-procédure-de-test)

## 1. Présentation

Ce document décrit la mise en place de la gestion automatisée des objets ordinateurs dans l'Active Directory du domaine **BillU.lan**, conformément aux objectifs du projet :

- Déplacement automatique des ordinateurs dans les bonnes OU
- Tri suivant le nom de la machine et/ou la valeur d'un attribut AD
- Automatisation par script PowerShell exécuté par une tâche planifiée
- Activation de la corbeille Active Directory

L'ensemble repose sur deux scripts PowerShell déposés dans `C:\Scripts\` sur le contrôleur de domaine `BV-100-101` :

| Fichier | Rôle | Exécution |
|---|---|---|
| `Move-ComputersToOU.ps1` | Script principal de tri et déplacement des ordinateurs | Automatique, toutes les heures (tâche planifiée) |
| `Setup-TaskAndRecycleBin.ps1` | Création de la tâche planifiée et activation de la corbeille AD | Une seule fois, manuellement, en administrateur |

## 2. Architecture Active Directory

Le domaine **BillU.lan** est organisé en trois OU racines. `BU_Admins` contient les comptes et machines d'administration (`Comptes_Admins`, `Computers_Admins`). `BU_Computers` accueille le parc informatique, réparti entre `Postes_Utilisateurs` et `Serveurs`. `BU_Users` regroupe les utilisateurs par service (Commercial, Communication, Comptabilite, Developpement_Logiciels, Direction, DSI, Juridique, Qualite, Recrutement).

Lorsqu'une machine est jointe au domaine, elle est créée par défaut dans le conteneur `CN=Computers,DC=BillU,DC=lan`. C'est ce conteneur que le script surveille : toute machine qui s'y trouve est analysée puis déplacée vers son OU définitive.

## 3. Convention de nommage et règles de tri

Le tri s'appuie d'abord sur le préfixe du nom de machine :

| Préfixe | Type de machine | OU de destination |
|---|---|---|
| `BV-*` | Serveur | `OU=Serveurs,OU=BU_Computers,DC=BillU,DC=lan` |
| `PC-*` | Poste utilisateur | `OU=Postes_Utilisateurs,OU=BU_Computers,DC=BillU,DC=lan` |
| `ADM-*` | Machine d'administration | `OU=Computers_Admins,OU=BU_Admins,DC=BillU,DC=lan` |

En complément, un second mécanisme exploite l'attribut AD `description` de l'objet ordinateur : si la description contient « Serveur », « Admin » ou « Poste », la machine est dirigée vers l'OU correspondante. Ce mécanisme sert de filet de sécurité lorsqu'une machine ne respecte pas la convention de nommage.

La variable `$Priority` du script détermine quelle règle l'emporte en cas de conflit ; elle est positionnée sur `"Name"` : le nom de la machine prime, l'attribut n'est utilisé que si aucun préfixe ne correspond.

Les contrôleurs de domaine ne sont jamais concernés : bien que `BV-100-101` commence par `BV-`, il réside dans l'OU `Domain Controllers`, qui n'est pas scannée par le script (seul le conteneur `Computers` l'est, en portée `OneLevel`).

## 4. Fonctionnement du script Move-ComputersToOU.ps1

À chaque exécution, le script importe le module ActiveDirectory puis liste les ordinateurs présents dans le conteneur source avec `Get-ADComputer`. Pour chaque machine, il détermine l'OU cible en appliquant d'abord la règle par nom, puis la règle par attribut. Si aucune règle ne correspond, la machine est ignorée et l'événement journalisé. Avant tout déplacement, le script vérifie que l'OU cible existe réellement et que la machine n'y est pas déjà. Le déplacement est ensuite effectué avec `Move-ADObject`.

Le script dispose d'un mode test piloté par la variable `$TestMode` en tête de fichier. À `$true`, les déplacements sont simulés (`-WhatIf`) et tracés avec la mention `[SIMULATION]` ; à `$false`, ils sont réellement exécutés. La première mise en service doit toujours se faire en mode test.

Chaque exécution produit un fichier de journal quotidien dans `C:\Scripts\Logs\` (format `MoveComputers_AAAA-MM-JJ.log`), horodaté ligne par ligne avec un niveau (`INFO`, `MOVE`, `SKIP`, `TEST`, `ERROR`) et un bilan final du nombre de machines déplacées, ignorées et en erreur.

## 5. Automatisation par tâche planifiée

L'énoncé du projet mentionne une « tâche AT ». La commande `at.exe` est obsolète et a été retirée de Windows Server depuis la version 2012 ; son successeur officiel est le **Planificateur de tâches**, utilisé ici via les cmdlets PowerShell `ScheduledTasks`. Ce choix technique est documenté et assumé : il s'agit de l'équivalent moderne, plus robuste (reprise après indisponibilité, limite de durée d'exécution, compte de service).

La tâche créée par le script d'installation se nomme **« AD - Deplacement automatique des ordinateurs »** et présente les caractéristiques suivantes : exécution de `powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Scripts\Move-ComputersToOU.ps1"`, déclenchement toutes les heures (répétition sur 10 ans), compte d'exécution `SYSTEM` avec niveau de privilèges le plus élevé, démarrage en différé si l'heure prévue a été manquée (`StartWhenAvailable`) et limite d'exécution de 30 minutes.

La fréquence se modifie dans le script d'installation (paramètre `-RepetitionInterval`) ou directement dans le Planificateur de tâches (`taskschd.msc`). Pour un environnement de production, l'utilisation d'un compte de service géré (gMSA) avec délégation de déplacement d'objets sur les OU concernées est recommandée à la place de SYSTEM.

## 6. Corbeille Active Directory

La corbeille AD (Recycle Bin) permet de restaurer intégralement un objet supprimé — attributs, appartenance aux groupes et liens compris — sans restauration autoritaire ni redémarrage en mode DSRM.

Points importants : son activation est **irréversible**, elle exige un niveau fonctionnel de forêt au minimum Windows Server 2008 R2 et des droits Enterprise Admins. Le script d'installation vérifie si elle est déjà active avant d'agir, puis l'active avec :

```powershell
Enable-ADOptionalFeature -Identity 'Recycle Bin Feature' `
    -Scope ForestOrConfigurationSet -Target (Get-ADForest).Name -Confirm:$false
```

### Vérification de l'activation

En PowerShell, la corbeille est active si le champ `EnabledScopes` n'est pas vide :

```powershell
Get-ADOptionalFeature -Filter 'Name -eq "Recycle Bin Feature"' |
    Select-Object Name, EnabledScopes
```

Graphiquement, ouvrir le **Centre d'administration Active Directory** (`dsac.exe`), sélectionner le domaine **BillU (local)** : un conteneur **Deleted Objects** est désormais visible, et le lien « Activer la corbeille... » du volet Tâches est grisé. À noter que la console ADUC classique n'affiche jamais ce conteneur, même avec les fonctionnalités avancées : la vérification visuelle passe obligatoirement par le Centre d'administration AD.

### Restauration d'un objet

En PowerShell :

```powershell
Get-ADObject -Filter 'Name -like "PC-TEST-01*"' -IncludeDeletedObjects |
    Restore-ADObject
```

Graphiquement : Centre d'administration AD → conteneur Deleted Objects → clic droit sur l'objet → **Restaurer** (emplacement d'origine) ou **Restaurer vers...** (autre OU). La durée de rétention des objets supprimés correspond au `msDS-deletedObjectLifetime` (180 jours par défaut).

## 7. Procédure d'installation

Copier les deux scripts dans `C:\Scripts\` sur le contrôleur de domaine. Ouvrir une console PowerShell **en administrateur**, puis débloquer les fichiers s'ils proviennent d'une autre machine :

```powershell
cd C:\Scripts
Unblock-File .\Setup-TaskAndRecycleBin.ps1
Unblock-File .\Move-ComputersToOU.ps1
.\Setup-TaskAndRecycleBin.ps1
```

Vérifier ensuite la tâche et la corbeille :

```powershell
Get-ScheduledTask -TaskName "AD - Deplacement automatique des ordinateurs"
Get-ADOptionalFeature -Filter 'Name -eq "Recycle Bin Feature"'
```

## 8. Procédure de test

Le test de bout en bout consiste à créer des objets fictifs dans le conteneur source, déclencher la tâche et constater le déplacement :

```powershell
# Création de machines de test
New-ADComputer -Name "PC-TEST-01" -Path "CN=Computers,DC=BillU,DC=lan"
New-ADComputer -Name "BV-TEST-01" -Path "CN=Computers,DC=BillU,DC=lan"

# Déclenchement immédiat de la tâche
Start-ScheduledTask -TaskName "AD - Deplacement automatique des ordinateurs"

# Contrôle du résultat
Get-ADComputer "PC-TEST-01" | Select-Object Name, DistinguishedName
Get-ADComputer "BV-TEST-01" | Select-Object Name, DistinguishedName
```

Résultat attendu : `PC-TEST-01` se retrouve dans `OU=Postes_Utilisateurs,OU=BU_Computers,DC=BillU,DC=lan` et `BV-TEST-01` dans `OU=Serveurs,OU=BU_Computers,DC=BillU,DC=lan`. Le détail de chaque décision est consultable dans `C:\Scripts\Logs\`.

Tant que `$TestMode = $true`, les machines ne bougent pas réellement et le log affiche `[SIMULATION]`. Le passage en production consiste simplement à positionner `$TestMode = $false`.

