# Présentation du document 

- Ce document a pour but d'expliquer les étapes pour corriger les vulnérabilités détéctées suite aux différents audit de sécurité.
- De préference les ajustement seront fait dans l'ordre de priorité via GPO, sinon via PowerShell et pour finir via Interface Graphique.

# Table des matières

- [**1. Déploiement de Windows LAPS (GPO)**](#1-déploiement-de-windows-laps-gpo)

## 1. Déploiement de Windows LAPS (GPO)

### Description de la faille
Sans LAPS, le compte **Administrateur local** de chaque machine du domaine partage généralement le même mot de passe.
Si un attaquant compromet une machine, il peut utiliser ce mot de passe pour se connecter en administrateur local sur toutes les autres machines du domaine.
**Windows LAPS** (Local Administrator Password Solution) résout ce problème en générant automatiquement un mot de passe unique par machine, en le stockant chiffré dans l'AD et en le renouvelant à intervalles réguliers.

### Correction
### Etape 1 - Extension du schéma AD
A effectuer une seule fois sur le domaine depuis le DC détenant le rôle **Schema Master**.
```
- Vérifier quel DC détient le rôle Schema Master :
  netdom query fsmo
- Etendre le schéma AD pour Windows LAPS :
  Update-LapsADSchema
```
**Vérification :**
```
Get-ADObject -SearchBase (Get-ADRootDSE).SchemaNamingContext -Filter {name -like "ms-LAPS*"}
```
Les attributs suivants doivent apparaitre :
```
ms-LAPS-EncryptedDSRMPassword
ms-LAPS-EncryptedDSRMPasswordHistory
ms-LAPS-EncryptedPassword
ms-LAPS-EncryptedPasswordHistory
ms-LAPS-Password
ms-LAPS-PasswordExpirationTime
```
---
### Etape 2 - Délégation des permissions sur les OUs
Chaque machine doit avoir le droit d'écrire son propre mot de passe dans l'AD.
La commande suivante est à répéter sur chaque OU contenant des machines :
```
Set-LapsADComputerSelfPermission -Identity "OU=BU_Computers,DC=BillU,DC=lan"
```
![SCHEMA_ETENDUE](Ressources/Schéma_étendu_permissions.png)

---
### Etape 3 - Configuration de la GPO LAPS
**Nom de la GPO :** `GPO-LAPS-Postes-v1.0`
```
- Ouvrir la console GPMC (gpmc.msc)
- Lier la GPO à l'OU BU_Computers (ou Postes_Utilisateurs)
- Clic droit sur la GPO - Edit
- Computer Configuration
  - Policies
    - Administrative Templates
      - System
        - LAPS
```
![GPO1](Ressources/GPO1.png)
![GPO2](Ressources/GPO2.png)

**Parametre 1 - Configure password backup directory**
```
- Enabled
- Backup directory : Active Directory
```
**Parametre 2 - Password Settings**
```
- Enabled
- Password complexity : Large letters + small letters + numbers + special characters
- Password length : 14
- Password age (days) : 30
```
**Parametre 3 - Enable password encryption**
```
- Enabled
```
---
### Etape 4 - Application et vérification
```
- Lancer gpupdate /force sur les machines cibles
- Vérifier la génération du mot de passe depuis le DC :
  Get-LapsADPassword -Identity "NOM-DE-LA-MACHINE" -AsPlainText
```
**Résultat attendu :**
```
ComputerName     : NOM-DE-LA-MACHINE
Account          : Administrateur
Password         : xxxxxxxxxxxxxxx
Source           : EncryptedPassword
DecryptionStatus : Success
AuthorizedDecryptor : BILLU\Domain Admins
```
---
### Etape 5 - Documentation de la rotation
```
- Etat avant rotation :
  Get-LapsADPassword -Identity "NOM-DE-LA-MACHINE" -AsPlainText
- Forcer une rotation manuelle sur le client :
  Reset-LapsPassword
- Etat après rotation :
  Get-LapsADPassword -Identity "NOM-DE-LA-MACHINE" -AsPlainText
````
![VERIF](Ressources/Console_laps_DC.png)

### Résultat
| Element | Avant | Après |
| --- | --- | --- |
| Mot de passe admin local | Identique sur toutes les machines | Unique par machine |
| Stockage du mot de passe | Non géré | Chiffré dans l'AD |
| Renouvellement | Manuel | Automatique tous les 30 jours |
| Accès au mot de passe | Non contrôlé | Réservé aux Domain Admins |
---
