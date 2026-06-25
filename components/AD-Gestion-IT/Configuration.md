# Configuration - AD Gestion IT des nouvelles règles RH

  

## 1. Gestion des départs de collaborateurs

  

### 1.1 Objectif

  

Lorsqu'un collaborateur quitte BillU, son compte Active Directory ne doit pas être supprimé.

  

Le compte est :

  

- désactivé ;

- déplacé dans une OU d'archivage ;

- conservé pour traçabilité ;

- documenté dans sa description ;

- retiré des groupes non nécessaires.

  

---

  

## 1.2 Fichier CSV utilisé

  

Chemin :

  

```text

C:\Scripts\departs_collaborateurs.csv

```

  

Exemple :

  

```csv

SamAccountName;DateDepart;Ticket

test.script;2026-06-23;RH-002

```

  

---

  

## 1.3 Script PowerShell de désactivation

  

Chemin du script :

  

```text

C:\Scripts\Disable-Leavers.ps1

```

  

Exemple de script :

  

```powershell

Import-Module ActiveDirectory

  

$CsvPath = "C:\Scripts\departs_collaborateurs.csv"

$ArchiveOU = "OU=BU_Anciens_Collaborateurs,DC=BillU,DC=lan"

$LogPath = "C:\Scripts\logs_departs_collaborateurs.txt"

  

$Users = Import-Csv -Path $CsvPath -Delimiter ";"

  

foreach ($User in $Users) {

  

    $Sam = $User.SamAccountName

    $DateDepart = $User.DateDepart

    $Ticket = $User.Ticket

  

    Write-Host "Traitement du compte : $Sam" -ForegroundColor Cyan

  

    try {

        $ADUser = Get-ADUser -Identity $Sam -Properties MemberOf, DistinguishedName, Description

  

        Disable-ADAccount -Identity $Sam

  

        foreach ($GroupDN in $ADUser.MemberOf) {

            $Group = Get-ADGroup -Identity $GroupDN

  

            if ($Group.Name -ne "Domain Users") {

                Remove-ADGroupMember -Identity $Group -Members $Sam -Confirm:$false

            }

        }

  

        Set-ADUser -Identity $Sam -Description "Compte desactive suite au depart du collaborateur - Date : $DateDepart - Ticket : $Ticket"

  

        Move-ADObject -Identity $ADUser.DistinguishedName -TargetPath $ArchiveOU

  

        Add-Content $LogPath "[$(Get-Date)] OK : $Sam desactive, groupes retires, deplace dans $ArchiveOU"

  

        Write-Host "Compte $Sam traite avec succes" -ForegroundColor Green

    }

    catch {

        Add-Content $LogPath "[$(Get-Date)] ERREUR : $Sam - $($_.Exception.Message)"

        Write-Host "Erreur avec le compte $Sam" -ForegroundColor Red

    }

}

```

  

---

  

## 1.4 Exécution du script

  

Commande :

  

```powershell

powershell.exe -ExecutionPolicy Bypass -File C:\Scripts\Disable-Leavers.ps1

```

  

---

  

## 1.5 Vérification

  

Vérifier l'état du compte :

  

```powershell

Get-ADUser test.script -Properties Enabled,Description,DistinguishedName |

Select-Object SamAccountName,Enabled,Description,DistinguishedName

```

  

Résultat attendu :

  

```text

Enabled : False

Description : Compte desactive suite au depart du collaborateur...

DistinguishedName : OU=BU_Anciens_Collaborateurs,DC=BillU,DC=lan

```

  

---

  

# 2. Féminisation des postes

  

## 2.1 Objectif

  

Les intitulés de postes occupés par des femmes sont féminisés dans l'Active Directory.

  

Seul l'attribut suivant est modifié :

  

```text

Title

```

  

L'attribut suivant est conservé :

  

```text

Department

```

  

---

  

## 2.2 Export CSV des utilisateurs

  

Commande utilisée :

  

```powershell

Get-ADUser -Filter * -SearchBase "OU=BU_Users,DC=BillU,DC=lan" -Properties Title,Department,Mail |

Select-Object SamAccountName,Name,Title,Department,Mail,@{Name="PosteFeminise";Expression={""}} |

Export-Csv "C:\Scripts\feminisation_postes.csv" -NoTypeInformation -Encoding UTF8 -Delimiter ";"

```

  

---

  

## 2.3 Fonctionnement du CSV

  

Fichier utilisé :

  

```text

C:\Scripts\feminisation_postes.csv

```

  

Colonnes :

  

```csv

SamAccountName;Name;Title;Department;Mail;PosteFeminise

```

  

Fonctionnement :

  

| Colonne | Rôle |

|---|---|

| SamAccountName | Identifiant AD |

| Name | Nom complet |

| Title | Poste source |

| Department | Département |

| Mail | Adresse mail |

| PosteFeminise | Marqueur de traitement |

  

Règle :

  

```text

PosteFeminise vide = compte ignoré

PosteFeminise rempli = compte traité

```

  

---

  

## 2.4 Exemples de règles de féminisation

  

| Poste source | Poste féminisé |

|---|---|

| Développeur | Développeuse |

| Directeur | Directrice |

| Technicien | Technicienne |

| Administrateur | Administratrice |

| Assistant de direction | Assistante de direction |

| Contrôleur de gestion | Contrôleuse de gestion |

| Rédacteur | Rédactrice |

| Acheteur | Acheteuse |

| Auditeur | Auditrice |

| Agent | Agente |

  

Certains postes sont déjà neutres ou identiques au féminin :

  

```text

Juriste

Comptable

Community manager

Responsable recrutement

Gestionnaire ADV

```

  

---

  

## 2.5 Script PowerShell de féminisation

  

Chemin :

  

```text

C:\Scripts\Update-FeminizedTitles.ps1

```

  

Le script utilise un mode test :

  

```powershell

$ModeTest = $true

```

  

Puis un mode réel :

  

```powershell

$ModeTest = $false

```

  

Le script repart du `Title` présent dans le CSV afin d'éviter de féminiser plusieurs fois un poste déjà modifié.

  

Exemple de problème évité :

  

```text

Assistante

Assistantee

Assistanteee

```

  

---

  

## 2.6 Exécution du script

  

En mode test :

  

```powershell

powershell.exe -ExecutionPolicy Bypass -File C:\Scripts\Update-FeminizedTitles.ps1

```

  

Après validation, passer le script en mode réel :

  

```powershell

$ModeTest = $false

```

  

Puis relancer :

  

```powershell

powershell.exe -ExecutionPolicy Bypass -File C:\Scripts\Update-FeminizedTitles.ps1

```

  

---

  

## 2.7 Vérification

  

Exemple :

  

```powershell

Get-ADUser nyamamoto -Properties Title,Department |

Select-Object SamAccountName,Title,Department

```

  

Résultat attendu :

  

```text

SamAccountName : nyamamoto

Title          : Assistante de direction

Department     : Direction

```

  

---

  

# 3. Gestion des logs

  

## 3.1 Logs départ collaborateur

  

Chemin :

  

```text

C:\Scripts\logs_departs_collaborateurs.txt

```

  

## 3.2 Logs féminisation des postes

  

Chemin :

  

```text

C:\Scripts\Logs\logs_feminisation_postes.txt

```

  

Les logs permettent de conserver une trace :

  

- des utilisateurs traités ;

- des anciennes valeurs ;

- des nouvelles valeurs ;

- des erreurs éventuelles ;

- des modifications appliquées.

  

---

  

# 4. Tests réalisés

  

## 4.1 Départ collaborateur

  

| Test | Résultat |

|---|---|

| Création de l'OU d'archivage | OK |

| Désactivation manuelle d'un utilisateur | OK |

| Déplacement manuel dans l'OU d'archive | OK |

| Exécution du script CSV | OK |

| Compte désactivé automatiquement | OK |

| Description mise à jour | OK |

| Log généré | OK |

  

## 4.2 Féminisation des postes

  

| Test | Résultat |

|---|---|

| Export des utilisateurs AD | OK |

| Ajout de la colonne PosteFeminise | OK |

| Traitement uniquement des lignes concernées | OK |

| Modification uniquement du Title | OK |

| Conservation du Department | OK |

| Correction des titres déjà modifiés | OK |

| Log généré | OK |

  

---

  

# 5. Points d'attention

  

- Ne jamais supprimer les comptes des collaborateurs sortants.

- Toujours tester les scripts sur un compte de test.

- Toujours réaliser un export de sauvegarde avant modification massive.

- Vérifier que les comptes de service ne sont pas marqués comme concernés.

- Vérifier les extensions de fichiers `.csv` et `.ps1`.

- Conserver les logs dans le dépôt ou en annexe de la documentation.
