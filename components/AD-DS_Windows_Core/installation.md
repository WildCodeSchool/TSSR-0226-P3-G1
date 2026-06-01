# Sommaire

- [**1. Préparation du serveur Windows Core**](#1-préparation-du-serveur-windows-core)
- [**2. Transfert des scripts sur le serveur**](#2-transfert-des-scripts-sur-le-serveur)
- [**3. Configuration du fichier config.json**](#3-configuration-du-fichier-configjson)
- [**4. Lancement du script d'installation**](#4-lancement-du-script-dinstallation)
- [**5. Vérification post-redémarrage**](#5-vérification-post-redémarrage)
- [**6. Ressources complémentaires**](#6-ressources-complémentaires)

---

# 1. Préparation du serveur Windows Core

## Connexion au serveur

Se connecter au serveur Windows Core avec le compte administrateur local :

```
Nom d'utilisateur : Administrator
Mot de passe      : Azerty1*
```

## Vérification de la version PowerShell

```powershell
$PSVersionTable.PSVersion
```

La version doit être **5.1** minimum.

## Création du dossier de scripts

```powershell
mkdir C:\Users\Administrator\SCRIPTS
cd C:\Users\Administrator\SCRIPTS
```

## Autorisation d'exécution des scripts

```powershell
Set-ExecutionPolicy RemoteSigned -Force
```

---

# 2. Transfert des scripts sur le serveur

## Depuis le PC Admin via SCP

Depuis un terminal sur le PC Admin, transférer les deux fichiers :

```bash
scp Install-ADDS.ps1 Administrator@172.16.10.252:C:/Users/Administrator/SCRIPTS/
scp config.json Administrator@172.16.10.252:C:/Users/Administrator/SCRIPTS/
```

## Vérification de la présence des fichiers

Sur le Server Core :

```powershell
ls C:\Users\Administrator\SCRIPTS\
```

Le résultat attendu :

```
Mode        LastWriteTime    Length  Name
----        -------------    ------  ----
-a----      xx/xx/xxxx       xxxxx   config.json
-a----      xx/xx/xxxx       xxxxx   Install-ADDS.ps1
```

---

# 3. Configuration du fichier config.json

Le fichier `config.json` contient tous les paramètres nécessaires à l'installation. Il est passé en argument au script principal.

## Contenu du fichier

```json
{
    "ServerName":     "BV-130-105",
    "IPAddress":      "172.16.10.252",
    "PrefixLength":   24,
    "DefaultGateway": "172.16.10.254",
    "DNSServer":      "172.16.10.253",
    "DomainName":     "BillU.lan",
    "NetbiosName":    "BILLU",
    "SiteName":       "Default-First-Site-Name",
    "DatabasePath":   "C:\\Windows\\NTDS",
    "LogPath":        "C:\\Windows\\NTDS",
    "SysvolPath":     "C:\\Windows\\SYSVOL"
}
```

## Description des paramètres

| Paramètre       | Description                                          |
| --------------- | ---------------------------------------------------- |
| `ServerName`    | Nom souhaité pour le serveur dans le domaine         |
| `IPAddress`     | Adresse IP statique du serveur                       |
| `PrefixLength`  | Longueur du masque réseau (24 = 255.255.255.0)       |
| `DefaultGateway`| Adresse IP de la passerelle                          |
| `DNSServer`     | Adresse IP du DC principal (DNS existant)            |
| `DomainName`    | Nom FQDN du domaine à rejoindre                      |
| `NetbiosName`   | Nom NetBIOS du domaine                               |
| `SiteName`      | Nom du site Active Directory                         |
| `DatabasePath`  | Chemin de stockage de la base NTDS                   |
| `LogPath`       | Chemin des logs AD DS                                |
| `SysvolPath`    | Chemin du dossier SYSVOL                             |


# 4. Lancement du script d'installation

## Lancer le script

```powershell
PowerShell.exe -ExecutionPolicy Bypass -File ".\Install-ADDS.ps1" -ConfigFile ".\config.json"
```

## Déroulement du script

Le script effectue automatiquement les étapes suivantes :

| Étape | Action                                              | Résultat attendu          |
| ----- | --------------------------------------------------- | ------------------------- |
| 1     | Lecture du `config.json`                            | `[SUCCESS] Configuration chargee` |
| 2     | Vérification des droits administrateur              | `[SUCCESS] Droits administrateur confirmes` |
| 3     | Renommage du serveur (si nécessaire)                | `[SUCCESS] Serveur renomme` ou `[INFO] Nom deja correct` |
| 4     | Configuration IP statique + DNS                     | `[SUCCESS] Reseau configure` |
| 5     | Test de connectivité vers le DC principal           | `[SUCCESS] DC principal joignable` |
| 6     | Installation du rôle AD DS                          | `[SUCCESS] Role AD DS installe` |
| 7     | Saisie des credentials du domaine                   | Fenêtre `Get-Credential` |
| 8     | Saisie du mot de passe DSRM                         | Prompt `Mot de passe DSRM` |
| 9     | Promotion en DC supplémentaire + redémarrage        | `[SUCCESS] Promotion reussie` |

## Saisie des credentials

Quand le script demande les credentials du domaine, entrer :

```
Nom d'utilisateur : BILLU\Administrator
Mot de passe      : Azerty1*
```

Le compte doit appartenir au groupe **Domain Admins** ou **Enterprise Admins**.

## Saisie du mot de passe DSRM

Le mot de passe DSRM (Directory Services Restore Mode) est un mot de passe de secours utilisé uniquement en cas de récupération du DC. Choisir un mot de passe fort et le noter précieusement :

```
Mot de passe DSRM : Azerty1*
```

Ce mot de passe est indépendant de tout compte du domaine. Ne pas le **perdre**.

## Suivi du log

Le script génère automatiquement un fichier log dans le dossier `SCRIPTS` :

```powershell
Get-Content ".\Install-ADDS_$(Get-Date -Format 'yyyyMMdd').log"
```

---

# 5. Vérification post-redémarrage

Après le redémarrage automatique du serveur, vérifier que la promotion a bien fonctionné.

## Lister les contrôleurs de domaine

```powershell
Get-ADDomainController -Filter * | Select-Object Name, IPv4Address, IsGlobalCatalog
```

Le résultat doit afficher les **deux DC** :

```
Name        IPv4Address     IsGlobalCatalog
----        -----------     ---------------
BV-100-101  172.16.10.253   True
BV-130-105  172.16.10.252   True
```

## Vérifier la réplication

```powershell
repadmin /replsummary
```

## Vérifier sur le DC principal

Sur le DC principal, ouvrir **Active Directory Users and Computers** :

- Naviguer dans `BillU.lan` > `Domain Controllers`
- Vérifier la présence de `BV-130-105`

---

# 6. Ressources complémentaires

- Documentation Microsoft AD DS : https://learn.microsoft.com/fr-fr/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview
- Install-ADDSDomainController : https://learn.microsoft.com/fr-fr/powershell/module/addsdeployment/install-addsdomaincontroller
