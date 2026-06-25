# Installation - AD Gestion IT des nouvelles règles RH

  

## 1. Prérequis

  
Avant de commencer, les éléments suivants doivent être disponibles :

  
- un domaine Active Directory fonctionnel ;

- un contrôleur de domaine Windows Server ;

- le module PowerShell ActiveDirectory installé ;

- un compte administrateur du domaine ;

- une OU contenant les utilisateurs de l'entreprise ;

- un dossier local pour stocker les scripts et fichiers CSV.

  

Dans le projet BillU, les informations utilisées sont :

  

```text

Domaine : BillU.lan

OU utilisateurs : OU=BU_Users,DC=BillU,DC=lan

Dossier scripts : C:\Scripts

```

  

---

  

## 2. Création du dossier de travail

  

Sur le contrôleur de domaine, créer le dossier suivant :

  

```powershell

New-Item -ItemType Directory -Path "C:\Scripts" -Force

```

  

Créer également un dossier pour les logs :

  

```powershell

New-Item -ItemType Directory -Path "C:\Scripts\Logs" -Force

```

  

---

  

# 3. Installation de la structure pour les départs de collaborateurs

  

## 3.1 Création de l'OU d'archivage

  

Les comptes des anciens collaborateurs doivent être déplacés dans une OU dédiée.

  

Créer l'OU suivante dans Active Directory Users and Computers :

  

```text

BU_Anciens_Collaborateurs

```

  

Chemin LDAP attendu :

  

```text

OU=BU_Anciens_Collaborateurs,DC=BillU,DC=lan

```

  

Création possible en PowerShell :

  

```powershell

New-ADOrganizationalUnit -Name "BU_Anciens_Collaborateurs" -Path "DC=BillU,DC=lan"

```

  

---

  

## 3.2 Création du fichier CSV des départs

  

Créer le fichier suivant :

  

```text

C:\Scripts\departs_collaborateurs.csv

```

  

Exemple de contenu :

  

```csv

SamAccountName;DateDepart;Ticket

test.script;2026-06-23;RH-002

```

  

Explication des colonnes :

  

| Colonne | Description |

|---|---|

| SamAccountName | Identifiant AD de l'utilisateur |

| DateDepart | Date de départ du collaborateur |

| Ticket | Référence du ticket RH |

  

---

  

## 3.3 Création du script de désactivation

  

Créer le fichier suivant :

  

```text

C:\Scripts\Disable-Leavers.ps1

```

  

Le script doit :

  

- importer le fichier CSV ;

- identifier les utilisateurs ;

- désactiver les comptes ;

- retirer les groupes non nécessaires ;

- mettre à jour la description ;

- déplacer les comptes dans l'OU d'archivage ;

- générer un log.

  

---

  

# 4. Installation de la structure pour la féminisation des postes

  

## 4.1 Export des utilisateurs AD

  

Un export CSV des utilisateurs est nécessaire afin d'identifier les collaboratrices concernées.

  

Commande d'export :

  

```powershell

Get-ADUser -Filter * -SearchBase "OU=BU_Users,DC=BillU,DC=lan" -Properties Title,Department,Mail |

Select-Object SamAccountName,Name,Title,Department,Mail,@{Name="PosteFeminise";Expression={""}} |

Export-Csv "C:\Scripts\feminisation_postes.csv" -NoTypeInformation -Encoding UTF8 -Delimiter ";"

```

  

Le fichier généré est :

  

```text

C:\Scripts\feminisation_postes.csv

```

  

---

  

## 4.2 Préparation du fichier CSV

  

Ouvrir le fichier CSV et renseigner la colonne `PosteFeminise` uniquement pour les collaboratrices concernées.

  

Exemple :

  

```csv

SamAccountName;Name;Title;Department;Mail;PosteFeminise

yabadi;Abadi Yara;Développeur;Développement logiciel;yabadi@BillU.lan;OUI

nyamamoto;Yamamoto Naomi;Assistant de direction;Direction;nyamamoto@BillU.lan;OUI

lduval;Duval Luca;Développeur;Développement logiciel;lduval@BillU.lan;

```

  

Fonctionnement :

  

```text

PosteFeminise vide   = utilisateur ignoré

PosteFeminise rempli = utilisateur traité

```

  

---

  

## 4.3 Création du script de féminisation

  

Créer le fichier suivant :

  

```text

C:\Scripts\Update-FeminizedTitles.ps1

```

  

Le script doit :

  

- lire le fichier `feminisation_postes.csv` ;

- traiter uniquement les lignes concernées ;

- convertir le poste au féminin ;

- modifier uniquement l'attribut AD `Title` ;

- conserver l'attribut `Department` ;

- générer un fichier de log.

  

---

  

## 5. Vérification des extensions de fichiers

  

Dans l'explorateur Windows, activer l'affichage des extensions :

  

```text

Affichage → Extensions de noms de fichiers

```

  

Cela permet d'éviter les erreurs comme :

  

```text

script.ps1.ps1

fichier.csv.csv

```

  

---

  

## 6. Vérification du module Active Directory

  

Tester le module Active Directory :

  

```powershell

Import-Module ActiveDirectory

Get-ADUser -Filter * | Select-Object -First 5

```

  

Si la commande retourne des utilisateurs, l'environnement est prêt.

  

---

  

## 7. Sauvegarde recommandée

  

Avant toute modification massive, réaliser un export des utilisateurs :

  

```powershell

Get-ADUser -Filter * -SearchBase "OU=BU_Users,DC=BillU,DC=lan" -Properties Title,Department,Mail,Description |

Select-Object SamAccountName,Name,Title,Department,Mail,Description |

Export-Csv "C:\Scripts\backup_users_avant_modification.csv" -NoTypeInformation -Encoding UTF8 -Delimiter ";"

```

  

Ce fichier permet de conserver l'état initial avant modification.
