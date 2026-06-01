# Sommaire

- [**1. Vérification post-installation**](#1-vérification-post-installation)
  - [**1.1 Vérification des contrôleurs de domaine**](#11-vérification-des-contrôleurs-de-domaine)
  - [**1.2 Vérification de la réplication**](#12-vérification-de-la-réplication)
  - [**1.3 Vérification du DNS**](#13-vérification-du-dns)
- [**2. Création des utilisateurs via script PowerShell**](#2-création-des-utilisateurs-via-script-powershell)
  - [**2.1 Prérequis**](#21-prérequis)
  - [**2.2 Lancement du script**](#22-lancement-du-script)
  - [**2.3 Résultat attendu**](#23-résultat-attendu)
- [**3. Vérification des utilisateurs dans l'AD**](#3-vérification-des-utilisateurs-dans-lad)
  - [**3.1 Via Active Directory Users and Computers**](#31-via-active-directory-users-and-computers)
  - [**3.2 Via PowerShell**](#32-via-powershell)



# 1. Vérification post-installation

Après le redémarrage du serveur suite à la promotion en DC supplémentaire, effectuer les vérifications suivantes.

## 1.1 Vérification des contrôleurs de domaine

Sur le **Server Core**, ouvrir PowerShell et taper :

```powershell
Get-ADDomainController -Filter * | Select-Object Name, IPv4Address, IsGlobalCatalog, Site
```

Le résultat attendu doit afficher **deux DC** :

| Name       | IPv4Address    | IsGlobalCatalog | Site                    |
| ---------- | -------------- | --------------- | ----------------------- |
| BV-100-101 | 172.16.10.253  | True            | Default-First-Site-Name |
| BV-130-105 | 172.16.10.252  | True            | Default-First-Site-Name |

Si `BV-130-105` n'apparaît pas, la promotion a échoué.

## 1.2 Vérification de la réplication

```powershell
repadmin /replsummary
```

Le résultat doit afficher **0 échecs** sur les deux DC :

```
Destination DSA          largest delta    fails/total %%   error
BV-100-101               00m:00s          0 /   5    0
BV-130-105               00m:00s          0 /   5    0
```

Pour forcer une réplication immédiate entre les deux DC :

```powershell
repadmin /syncall /AdeP
```

## 1.3 Vérification du DNS

```powershell
Resolve-DnsName BillU.lan
```

```powershell
Resolve-DnsName BV-100-101.BillU.lan
Resolve-DnsName BV-130-105.BillU.lan
```
---

# 2. Création des utilisateurs via script PowerShell

## 2.1 Prérequis

Avant de lancer le script, s'assurer que les deux fichiers suivants sont présents dans le même dossier :

| Fichier                          | Description                              |
| -------------------------------- | ---------------------------------------- |
| `BillU_Creation_Users_AD.ps1`    | Script de création des utilisateurs      |
| `s01-a02-BillU-ListeRHCollaborateurs.csv` | Fichier CSV contenant la liste RH |

> Le fichier CSV doit être encodé en **UTF-8** et utiliser la virgule `,` comme séparateur.

Le CSV doit contenir les colonnes suivantes :

| Colonne             | Description                        |
| ------------------- | ---------------------------------- |
| `Prenom`            | Prénom de l'utilisateur            |
| `Nom`               | Nom de l'utilisateur               |
| `Societe`           | Doit être `BillU` pour être traité |
| `Departement`       | Détermine l'OU de destination      |
| `fonction`          | Titre du poste                     |
| `Date de naissance` | Format `dd/MM/yyyy`                |
| `Telephone fixe`    | Téléphone fixe (ou `-`)            |
| `Telephone portable`| Téléphone mobile (ou `-`)          |

## 2.2 Lancement du script

Ouvrir PowerShell en tant qu'administrateur et se placer dans le dossier contenant les fichiers :

```powershell
cd C:\Scripts
```

Lancer le script :

```powershell
PowerShell.exe -ExecutionPolicy Bypass -File ".\BillU_Creation_Users_AD.ps1"
```

## 2.3 Résultat attendu

Le script affiche en temps réel le statut de chaque utilisateur :

| Couleur      | Statut      | Signification                              |
| ------------ | ----------- | ------------------------------------------ |
| Vert      | `[ CREE ]`  | Compte créé avec succès                    |
| Jaune     | `[ EXISTANT ]` | Compte déjà existant, ignoré            |
|  Magenta   | `[ DOUBLON ]`  | Login de base pris, date de naissance ajoutée |
|  Gris      | `[ IGNORE ]`   | Utilisateur non BillU, ignoré           |
|  Rouge     | `[ ERREUR ]`   | Erreur lors de la création              |

En fin d'exécution, un résumé s'affiche :

```
============================================================
   Resume de l'execution
============================================================
  Comptes crees     : 35
  Comptes existants : 0
  Lignes ignorees   : 5
  Total traite      : 40
============================================================
```

### Gestion des doublons

En cas de doublon sur le login (ex: deux `apatel`), le script ajoute automatiquement la **date de naissance** au format `DDMMYYYY` :

```
apatel          ← login de base (déjà pris)
apatel21041990  ← login avec date de naissance
```

### Mot de passe par défaut

Tous les comptes sont créés avec le mot de passe temporaire :

```
Azerty1*
```

> L'option `Changer le mot de passe à la prochaine connexion` est activée automatiquement sur tous les comptes.

---

# 3. Vérification des utilisateurs dans l'AD

## 3.1 Via Active Directory Users and Computers

Sur le DC principal, ouvrir **Active Directory Users and Computers** :

- Naviguer dans `BillU.lan` > `BU-Users`
- Vérifier la présence des utilisateurs dans chaque OU :

| OU                          | Département CSV correspondant         |
| --------------------------- | ------------------------------------- |
| `Commercial`                | Service Commercial                    |
| `Communication`             | Communication et Relations publiques  |
| `Comptabilite`              | Finance et Comptabilité               |
| `Developpement`             | Développement logiciel                |
| `Direction/Qualite/Recrutement` | Direction / QHSE / Recrutement    |
| `DSI`                       | DSI                                   |
| `Juridique`                 | Département Juridique                 |

## 3.2 Via PowerShell

Lister tous les utilisateurs créés dans `BU-Users` :

```powershell
Get-ADUser -Filter * -SearchBase "ou=BU-Users,dc=BillU,dc=lan" -Properties DisplayName, Department, Title, Enabled | Select-Object DisplayName, Department, Title, Enabled | Sort-Object Department
```

