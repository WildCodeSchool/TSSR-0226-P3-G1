- [**1. Audit des permissions NTFS avec AccessEnum**](#1-audit-des-permissions-ntfs-avec-accessEnum)
- [**2. Audit des permissions avec AccessChk**](#2-audit-des-permissions-avec-accessChk)
- [**3. Test de ShareEnum**](#3-test-de-shareEnum)
- [**4. Audit SMB natif avec PowerShell**](#4-audit-smb-natif-avec-powerShell)




## 1. Audit des permissions NTFS avec AccessEnum

### Objectif

L'objectif de cet audit est de vérifier les permissions NTFS appliquées sur le dossier de partage principal du serveur de stockage.

Cet audit permet de contrôler que les utilisateurs et les groupes Active Directory disposent uniquement des accès nécessaires à leurs dossiers respectifs.

L'objectif est également d'identifier d'éventuelles permissions trop larges, comme :

- `Everyone`
- `Domain Users`
- `Authenticated Users`
- droits en écriture non justifiés
- droits de modification ou de contrôle total trop permissifs

---

### Périmètre de l'audit

L'audit a été réalisé sur le serveur de stockage Windows.

Dossier audité :

```text
K:\Shares\Dossier_partage
```

Ce dossier contient les espaces partagés de l'entreprise, notamment :

- les dossiers personnels des utilisateurs ;
- les dossiers communs ;
- les dossiers de départements ;
- les dossiers liés aux services de l'entreprise.

---

### Outil utilisé

L'outil utilisé pour cet audit est `AccessEnum`, fourni par Microsoft Sysinternals.

AccessEnum permet d'analyser rapidement les permissions NTFS appliquées sur une arborescence de dossiers.

Il affiche notamment :

- les chemins analysés ;
- les groupes ou utilisateurs ayant des droits en lecture ;
- les groupes ou utilisateurs ayant des droits en écriture ;
- les éventuelles permissions particulières.

---

### Lancement de l'audit

L'outil `AccessEnum` a été lancé directement depuis le serveur de stockage afin d'analyser les permissions NTFS locales.

Chemin sélectionné dans AccessEnum :

```text
K:\Shares\Dossier_partage
```

L'audit a ensuite été lancé avec le bouton `Scan`.

Cette méthode permet d'analyser le dossier parent ainsi que l'ensemble des sous-dossiers présents dans l'arborescence.

---

### Résultat du scan AccessEnum

Le scan AccessEnum a permis de visualiser les permissions NTFS appliquées aux différents dossiers.

Les dossiers personnels des utilisateurs sont configurés de manière à limiter l'accès à :

- l'utilisateur propriétaire du dossier ;
- les administrateurs ;
- les groupes d'administration nécessaires.

Exemple observé :

```text
K:\Shares\Dossier_partage\Utilisateurs\nom_utilisateur
```

Le dossier personnel est accessible en écriture uniquement par l'utilisateur concerné et les administrateurs.

![Scan_AccessEnum](Ressources/Scan_AccessEnum.png)
---

### Analyse des dossiers de départements

Les dossiers de départements sont cloisonnés par groupes Active Directory.

Chaque service dispose de son propre groupe, qui est autorisé uniquement sur le dossier correspondant.

Exemples observés :

| Dossier | Groupe autorisé |
|---|---|
| `Departement\Commercial` | `GrpCommercial` |
| `Departement\Communication` | `GrpCommunication` |
| `Departement\Developpement_Logiciels` | `GrpDeveloppement` |
| `Departement\Direction` | `GrpDirection` |
| `Commun\Departements\DSI` | `BU_DL_Commun_DSI_M` |
| `Commun\Departements\Direction` | `BU_DL_Commun_Direction_M` |
| `Commun\Transverse` | `BU_DL_Commun_Transverse_M` |

Cette organisation permet de respecter le principe du moindre privilège.

Chaque groupe dispose uniquement des droits nécessaires sur son propre espace de travail.

---

### Vérification des droits sur le dossier racine

Le dossier racine du partage a également été vérifié depuis l'onglet `Security`.

Chemin vérifié :

```text
K:\Shares\Dossier_partage
```

Les droits observés sont les suivants :

| Groupe / utilisateur | Droits |
|---|---|
| `SYSTEM` | Droits système |
| `Administrators` | Contrôle total |
| `Users` | Lecture, exécution et affichage du contenu |

Les utilisateurs disposent uniquement des droits nécessaires pour parcourir l'arborescence.

Les droits d'écriture sont ensuite appliqués uniquement sur les sous-dossiers autorisés par groupe ou par utilisateur.

---

### Vérification complémentaire des permissions de partage SMB

En complément de l'audit NTFS réalisé avec AccessEnum, les permissions du partage SMB ont été vérifiées depuis les propriétés du dossier partagé.

Chemin :

```text
Dossier_partage
→ Properties
→ Share Permissions
```

Lors de la vérification, le groupe `Everyone` était présent dans les permissions du partage.

Afin d'améliorer la sécurité, ce groupe a été retiré.

La configuration finale du partage est la suivante :

| Groupe | Full Control | Change | Read | Rôle |
|---|---:|---:|---:|---|
| `GRP-T2-ADMIN` | Oui | Oui | Oui | Administration complète du partage |
| `Domain Users` | Non | Oui | Oui | Accès réseau au partage pour les utilisateurs du domaine |
| `Everyone` | Non | Non | Non | Groupe supprimé du partage |

![Droit_admin](Ressources/Droit_Admin.png)
![Droit_Domaine_User](Ressources/Droit_Domaine_User.png)
---

### Explication de la configuration

La sécurité d'accès au partage repose sur deux niveaux de permissions :

| Niveau | Rôle |
|---|---|
| Permissions de partage SMB | Autorisent l'accès au partage depuis le réseau |
| Permissions NTFS | Définissent précisément les droits sur les dossiers et fichiers |

Dans cette configuration :

- `Domain Users` peut accéder au partage depuis le réseau ;
- `GRP-T2-ADMIN` peut administrer le partage ;
- les permissions NTFS limitent ensuite l'accès aux dossiers autorisés ;
- chaque groupe métier accède uniquement à son propre dossier ;
- le groupe `Everyone` n'est plus utilisé sur le partage.

---

### Points de contrôle réalisés

Les vérifications suivantes ont été réalisées :

| Point contrôlé | Résultat |
|---|---|
| Scan du dossier parent avec AccessEnum | OK |
| Scan des sous-dossiers | OK |
| Vérification des dossiers utilisateurs | OK |
| Vérification des dossiers de départements | OK |
| Présence de groupes métiers dédiés | OK |
| Cloisonnement des accès par service | OK |
| Vérification des permissions SMB | OK |
| Suppression du groupe `Everyone` du partage | OK |
| Conservation de l'accès réseau pour `Domain Users` | OK |
| Administration réservée au groupe `GRP-T2-ADMIN` | OK |

---

### Risques recherchés pendant l'audit

L'audit avait pour objectif d'identifier les mauvaises pratiques suivantes :

| Risque recherché | Exemple |
|---|---|
| Accès trop large | `Everyone` avec droits d'écriture |
| Droits excessifs | `Domain Users` avec contrôle total |
| Mauvais cloisonnement | Tous les services accèdent au même dossier |
| Dossier sensible trop ouvert | Comptabilité accessible à tous |
| Permissions non maîtrisées | Droits hérités non contrôlés |

Aucune anomalie critique de ce type n'a été constatée sur les dossiers de départements affichés.

---

### Conclusion

L'audit réalisé avec AccessEnum a permis de vérifier les permissions NTFS du dossier de partage principal du serveur de stockage.

Les résultats montrent que les dossiers sont correctement organisés par service et par utilisateur.

Les dossiers de départements sont cloisonnés grâce à des groupes Active Directory dédiés. Chaque groupe dispose uniquement des droits nécessaires sur son propre dossier.

Une vérification complémentaire des permissions SMB a également été réalisée. Le groupe `Everyone` a été retiré du partage afin de renforcer la sécurité.

La configuration finale permet donc :

- un accès réseau contrôlé au partage ;
- une administration réservée aux administrateurs ;
- un cloisonnement des droits par service ;
- une limitation des accès selon les groupes Active Directory ;
- une réduction des permissions trop larges.

L'audit est considéré comme conforme aux bonnes pratiques de sécurité Windows Server.


## 2. Audit des permissions avec AccessChk

### Objectif

L'objectif de cet audit est de vérifier précisément les permissions appliquées sur le dossier de partage principal du serveur de stockage Windows.

L'outil utilisé est `AccessChk`, issu de la suite Microsoft Sysinternals.  
Il permet de contrôler les droits effectifs d'un utilisateur ou d'un groupe sur un fichier, un dossier, un service ou une clé de registre.

Dans notre cas, AccessChk est utilisé pour vérifier les droits d'accès sur le dossier suivant :

```text
K:\Shares\Dossier_partage
```

L'audit permet de confirmer que :

- les utilisateurs du domaine ne disposent pas de droits d'écriture directs sur la racine du partage ;
- les administrateurs disposent bien des droits nécessaires ;
- le groupe d'administration `GRP-T2-ADMIN` possède les droits attendus ;
- les permissions respectent le principe du moindre privilège.

---

### Machine utilisée

L'audit a été réalisé directement depuis le serveur de stockage Windows.

| Élément | Valeur |
|---|---|
| Serveur audité | `BV-130-153` |
| Dossier audité | `K:\Shares\Dossier_partage` |
| Outil utilisé | `accesschk64.exe` |
| Type d'audit | Vérification des droits d'écriture |

L'outil a été lancé depuis le dossier suivant :

```text
C:\Users\Administrator\Desktop\Audit_Windows\tools
```

---

### Commandes utilisées

Les commandes ont été exécutées depuis une invite de commandes lancée en administrateur.

#### Vérification des droits de `Domain Users`

```cmd
accesschk64.exe -accepteula -d -w "BILLU\Domain Users" "K:\Shares\Dossier_partage"
```

Résultat obtenu :

```text
No matching objects found.
```

Ce résultat indique que le groupe `Domain Users` ne possède pas de droit d'écriture direct sur la racine du partage.

#### Vérification des droits de `BUILTIN\Administrators`

```cmd
accesschk64.exe -accepteula -d -w "BUILTIN\Administrators" "K:\Shares\Dossier_partage"
```

Résultat obtenu :

```text
RW K:\Shares\Dossier_partage
```

Le résultat `RW` signifie :

| Lettre | Signification |
|---|---|
| `R` | Read |
| `W` | Write |

Le groupe `BUILTIN\Administrators` dispose donc bien de droits en lecture et en écriture sur le dossier audité.

#### Vérification des droits de `GRP-T2-ADMIN`

```cmd
accesschk64.exe -accepteula -d -w "BILLU\GRP-T2-ADMIN" "K:\Shares\Dossier_partage"
```

Résultat obtenu :

```text
RW K:\Shares\Dossier_partage
```

Le groupe `GRP-T2-ADMIN` dispose également de droits en lecture et en écriture sur le dossier racine du partage.

---

### Résultats de l'audit

| Groupe testé | Chemin audité | Résultat AccessChk | Interprétation |
|---|---|---|---|
| `BILLU\Domain Users` | `K:\Shares\Dossier_partage` | `No matching objects found` | Aucun droit d'écriture direct détecté |
| `BUILTIN\Administrators` | `K:\Shares\Dossier_partage` | `RW` | Droits de lecture et d'écriture présents |
| `BILLU\GRP-T2-ADMIN` | `K:\Shares\Dossier_partage` | `RW` | Droits de lecture et d'écriture présents |

---

### Analyse

Le test réalisé sur le groupe `Domain Users` montre qu'aucun droit d'écriture direct n'est appliqué sur la racine du partage.

Cela est important, car la racine d'un partage ne doit pas permettre aux utilisateurs standards de créer librement des fichiers ou dossiers. Les utilisateurs doivent uniquement accéder aux sous-dossiers pour lesquels ils sont autorisés.

Les tests réalisés sur `BUILTIN\Administrators` et `GRP-T2-ADMIN` montrent que les groupes d'administration disposent bien des droits nécessaires pour gérer le dossier de partage.

Cette configuration permet de séparer clairement :

- les accès standards des utilisateurs ;
- les droits d'administration ;
- les permissions spécifiques appliquées aux sous-dossiers.

---

### Complément avec les permissions SMB

En complément de l'audit AccessChk, les permissions du partage SMB ont été vérifiées depuis l'interface graphique Windows.

Configuration finale du partage :

| Groupe | Full Control | Change | Read | Rôle |
|---|---:|---:|---:|---|
| `GRP-T2-ADMIN` | Oui | Oui | Oui | Administration complète du partage |
| `Domain Users` | Non | Oui | Oui | Accès réseau au partage |
| `Everyone` | Non | Non | Non | Groupe supprimé du partage |

Cette configuration permet aux utilisateurs du domaine d'atteindre le partage réseau, tandis que les permissions NTFS limitent précisément l'accès aux dossiers autorisés.

---

### Conclusion

L'audit réalisé avec AccessChk confirme que la configuration des droits sur la racine du partage est cohérente.

Le groupe `Domain Users` ne possède pas de droits d'écriture directs sur la racine du partage.  
Les groupes d'administration `BUILTIN\Administrators` et `GRP-T2-ADMIN` disposent bien des droits nécessaires.

Les permissions respectent donc le principe du moindre privilège :

- les utilisateurs standards n'ont pas de droits excessifs sur la racine ;
- les administrateurs disposent des droits nécessaires ;
- les accès détaillés sont gérés au niveau des sous-dossiers par les permissions NTFS.

Cette phase complète l'audit réalisé avec AccessEnum.

---

### Captures d'écran

![AccessChk - Domain Users sans droit d'écriture](Ressources/DOMAIN_USERS.png)

![AccessChk - Administrators avec droits RW](Ressources/ADMIN.png)

![AccessChk - GRP-T2-ADMIN avec droits RW](Ressources/GRP-T2.png)


## 3. Test de ShareEnum

### Objectif initial

L'objectif initial était d'utiliser l'outil `ShareEnum` afin d'inventorier les partages SMB présents sur le domaine BillU.

ShareEnum devait permettre d'identifier :

- les partages réseau accessibles ;
- les chemins locaux associés aux partages ;
- les permissions appliquées sur les partages ;
- les éventuels droits trop permissifs ;
- la présence de groupes larges comme `Everyone`, `Domain Users` ou `Authenticated Users`.

---

### Machine utilisée

L'outil a été testé depuis plusieurs machines du domaine afin de vérifier son fonctionnement.

| Machine | Résultat |
|---|---|
| PC Admin | Échec de détection du domaine |
| Contrôleur de domaine / AD | Échec de détection du domaine |

L'outil a été lancé en tant qu'administrateur depuis le dossier contenant les outils d'audit.

---

### Problème rencontré

Lors du lancement de ShareEnum, l'outil n'a pas réussi à détecter le domaine ou les groupes de travail disponibles sur le réseau.

Message obtenu :

```text
No domains or workgroups were found on your network
```

Ce message est apparu malgré les tests effectués depuis le PC Admin et depuis le contrôleur de domaine.

Capture associée :

![Shareenum](Ressources/ShareEnum.png)

---

### Analyse du problème

ShareEnum repose sur des mécanismes de découverte réseau Windows plus anciens, notamment l'énumération des domaines, des groupes de travail et des partages SMB visibles sur le réseau.

Dans notre environnement de lab, cette découverte automatique n'a pas fonctionné.

Plusieurs causes peuvent expliquer ce comportement :

- découverte réseau Windows désactivée ou limitée ;
- filtrage réseau entre les différentes zones ;
- environnement segmenté avec plusieurs sous-réseaux ;
- fonctionnement limité de NetBIOS / SMB pour l'énumération réseau ;
- outil ancien et moins adapté aux environnements Active Directory modernes ou segmentés.

L'échec de ShareEnum ne signifie donc pas que le domaine ou les partages SMB sont mal configurés. Cela indique simplement que l'outil n'a pas réussi à énumérer automatiquement les ressources réseau dans cet environnement.

---

### Décision prise

Comme ShareEnum n'a pas permis d'obtenir un résultat exploitable, l'audit des partages SMB a été poursuivi avec d'autres méthodes.

Méthodes utilisées à la place :

| Méthode | Rôle |
|---|---|
| Vérification manuelle des permissions SMB | Contrôle des droits de partage depuis l'interface graphique Windows |
| AccessEnum | Audit des permissions NTFS sur l'arborescence du dossier partagé |
| AccessChk | Vérification ciblée des droits d'écriture par groupe |
| PowerHuntShares | Audit complémentaire des partages SMB du domaine |

---

### Résultat de remplacement

Même si ShareEnum n'a pas pu être exploité, les permissions du partage principal ont été vérifiées manuellement.

Partage concerné :

```text
K:\Shares\Dossier_partage
```

La configuration finale du partage SMB est la suivante :

| Groupe | Full Control | Change | Read | Rôle |
|---|---:|---:|---:|---|
| `GRP-T2-ADMIN` | Oui | Oui | Oui | Administration complète du partage |
| `Domain Users` | Non | Oui | Oui | Accès réseau au partage |
| `Everyone` | Non | Non | Non | Groupe supprimé du partage |

Cette vérification a permis de confirmer que le groupe `Everyone` n'est plus utilisé sur le partage et que les accès sont limités à des groupes identifiés.

---

### Conclusion

ShareEnum a bien été testé dans le cadre de l'audit des serveurs Windows, mais l'outil n'a pas permis d'obtenir de résultats exploitables dans l'environnement BillU.

L'erreur rencontrée indique que ShareEnum n'a pas réussi à détecter les domaines ou groupes de travail disponibles sur le réseau.

L'outil étant ancien et dépendant de mécanismes de découverte réseau parfois désactivés ou limités, il a été écarté au profit d'autres méthodes plus adaptées.

L'audit SMB a donc été poursuivi avec :

- une vérification manuelle des permissions de partage ;
- AccessEnum pour les permissions NTFS ;
- AccessChk pour les contrôles ciblés ;
- PowerHuntShares pour l'audit complémentaire des partages SMB.

Cette approche permet de conserver une démarche d'audit complète malgré l'impossibilité d'exploiter ShareEnum.


## 4. Audit SMB natif avec PowerShell

### Contexte

L'outil `PowerHuntShares` devait initialement être utilisé afin de réaliser un audit des partages SMB du domaine.

Cependant, lors de son import dans PowerShell, Microsoft Defender a bloqué le module en le détectant comme un contenu potentiellement malveillant.

Message rencontré :

```text
Ce script dont le contenu est malveillant a été bloqué par votre logiciel antivirus.
```
![message-erreur](Ressources/Defender_bloque.png)

Malgré la restauration du fichier et la création d'exclusions dans Microsoft Defender, le module a continué à être bloqué au moment de son import.

![exclusion](Ressources/Exclusion.png)

Par mesure de sécurité, la protection antivirus n'a pas été désactivée.  
Il a donc été décidé de réaliser un audit équivalent avec les commandes PowerShell natives de Windows.

---

### Objectif de l'audit

L'objectif de cet audit est d'inventorier les partages SMB du serveur de stockage et de vérifier les permissions appliquées sur ces partages.

L'audit permet de contrôler :

- la liste des partages SMB présents sur le serveur ;
- les chemins locaux associés aux partages ;
- les groupes autorisés ;
- les droits appliqués ;
- la présence éventuelle de permissions trop larges ;
- les droits accordés à des groupes sensibles comme `Everyone`, `Domain Users` ou `Authenticated Users`.

---

### Machine utilisée

L'audit a été lancé depuis le PC Admin à l'aide d'une session CIM vers le serveur de stockage.

| Élément | Valeur |
|---|---|
| Machine d'administration | `PC Admin` |
| Serveur audité | `BV-130-153` |
| Méthode utilisée | PowerShell natif |
| Type d'audit | Audit des partages SMB |
| Outil initialement prévu | `PowerHuntShares` |
| Solution de secours | Commandes SMB natives PowerShell |

---

### Création de la session CIM

Une session CIM a été créée afin d'interroger à distance le serveur de stockage.

```powershell
$Server = "BV-130-153"
$Session = New-CimSession -ComputerName $Server
```

Cette session permet d'exécuter les commandes SMB sur le serveur cible depuis le PC Admin.

---

### Liste des partages SMB

La commande suivante a été utilisée pour lister les partages SMB du serveur de stockage :

```powershell
Get-SmbShare -CimSession $Session
```

Résultat obtenu :

```text
Name              Path                          Description
----              ----                          -----------
ADMIN$            C:\Windows                    Remote Admin
Backup            K:\Backup
C$                C:\                           Default share
Dossier_partage   K:\Shares\Dossier_partage
IPC$                                            Remote IPC
K$                K:\                           Default share
```

Les partages administratifs comme `ADMIN$`, `C$`, `IPC$` et `K$` sont des partages système standards de Windows.

Les partages métiers identifiés sont :

| Partage | Chemin local | Rôle |
|---|---|---|
| `Backup` | `K:\Backup` | Dossier de sauvegarde |
| `Dossier_partage` | `K:\Shares\Dossier_partage` | Partage principal des utilisateurs et services |

---

### Vérification des permissions du partage principal

La commande suivante a été utilisée pour vérifier les permissions du partage `Dossier_partage` :

```powershell
Get-SmbShareAccess -CimSession $Session -Name "Dossier_partage"
```

Résultat obtenu :

```text
Name              AccountName              AccessControlType   AccessRight
----              -----------              -----------------   -----------
Dossier_partage   BILLU\GRP-T2-ADMIN        Allow               Full
Dossier_partage   BILLU\Domain Users        Allow               Change
```
![SMB](Ressources/Dossier_partage_SMB.png)

Analyse :

| Groupe | Droit SMB | Analyse |
|---|---|---|
| `BILLU\GRP-T2-ADMIN` | `Full` | Groupe d'administration autorisé à gérer le partage |
| `BILLU\Domain Users` | `Change` | Accès réseau au partage pour les utilisateurs du domaine |

Le groupe `Everyone` n'est pas présent sur le partage `Dossier_partage`.

Cette configuration est cohérente, car les utilisateurs peuvent atteindre le partage réseau, mais les accès précis sont ensuite limités par les permissions NTFS appliquées aux sous-dossiers.

---

### Recherche des permissions sensibles

Une recherche a été effectuée afin d'identifier les groupes larges ou sensibles présents dans les permissions SMB.

Commande utilisée :

```powershell
$Audit | Where-Object {
    $_.AccountName -match "Everyone|Tout le monde|Authenticated Users|Utilisateurs authentifiés|Domain Users"
} | Format-Table -AutoSize
```

Résultat obtenu :

```text
ShareName         Path                          AccountName          AccessControlType AccessRight
---------         ----                          -----------          ----------------- -----------
Backup            K:\Backup                     Everyone             Allow             Full
Dossier_partage   K:\Shares\Dossier_partage     BILLU\Domain Users   Allow             Change
```
![Permission_SMB](Ressources/Permission_SMB.png)

---

### Analyse des résultats

L'audit a permis d'identifier deux éléments importants.

#### Partage `Dossier_partage`

Le partage principal est configuré de manière cohérente :

| Groupe | Droit | État |
|---|---|---|
| `BILLU\GRP-T2-ADMIN` | Full | Conforme |
| `BILLU\Domain Users` | Change | Conforme avec contrôle NTFS |
| `Everyone` | Aucun droit | Conforme |

Le droit `Change` accordé à `Domain Users` permet l'accès réseau au partage.  
Les permissions NTFS contrôlent ensuite précisément les accès aux sous-dossiers.

#### Partage `Backup`

Le partage `Backup` présente une permission trop large :

| Groupe | Droit | État |
|---|---|---|
| `Everyone` | Full | Non conforme |

Le groupe `Everyone` avec le droit `Full` représente un risque, car il peut permettre à un trop grand nombre d'utilisateurs d'accéder ou de modifier des données de sauvegarde.

![rech_perm_smb.png](Ressources/rech_perm_smb.png)

---

### Risque identifié

Le droit `Everyone : Full` sur le partage `Backup` présente plusieurs risques :

- accès trop large aux données de sauvegarde ;
- modification ou suppression possible de fichiers de sauvegarde ;
- non-respect du principe du moindre privilège ;
- risque d'impact en cas de compte compromis ;
- exposition inutile d'un dossier sensible.

---

### Recommandation de correction

La configuration recommandée pour le partage `Backup` est la suivante :

| Groupe / Compte | Droit recommandé |
|---|---|
| `BILLU\GRP-T2-ADMIN` | Full |
| Compte de service de sauvegarde | Change ou Full selon le besoin |
| `Everyone` | Supprimé |

Le partage `Backup` ne doit pas être accessible en contrôle total à tous les utilisateurs.

---

### Export des résultats

Les résultats de l'audit ont été exportés au format CSV dans le dossier suivant :

```text
C:\Users\PCADMIN\Desktop\Audit_Windows\Exports\Audit_SMB_Natif
```

Fichiers générés :

```text
01_liste_partages_smb.csv
02_permissions_partages_smb.csv
```

Ces exports permettent de conserver une trace des partages SMB et des permissions observées pendant l'audit.

---

### Cohérence avec les audits précédents

Les résultats de l'audit PowerShell natif complètent les audits réalisés précédemment :

| Audit | Résultat |
|---|---|
| AccessEnum | Vérification des permissions NTFS |
| AccessChk | Vérification ciblée des droits d'écriture |
| ShareEnum | Testé mais non exploitable dans l'environnement |
| PowerHuntShares | Bloqué par Microsoft Defender |
| PowerShell natif SMB | Audit SMB réalisé avec succès |

---

### Conclusion

PowerHuntShares n'a pas pu être utilisé dans l'environnement, car Microsoft Defender a bloqué le module malgré la restauration du fichier et la création d'exclusions.

Afin de conserver une démarche d'audit propre et de ne pas désactiver l'antivirus, un audit équivalent a été réalisé avec les commandes PowerShell natives de Windows.

Cet audit a permis de :

- lister les partages SMB du serveur de stockage ;
- identifier les partages métiers ;
- vérifier les permissions du partage `Dossier_partage` ;
- confirmer l'absence du groupe `Everyone` sur le partage principal ;
- détecter une anomalie sur le partage `Backup`.

Le partage `Dossier_partage` est conforme à la configuration attendue.  
Le partage `Backup` nécessite une correction, car le groupe `Everyone` dispose actuellement du droit `Full`.

---


