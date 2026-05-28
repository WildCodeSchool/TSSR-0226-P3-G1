######################################################################################################
#                                                                                                    #
#   BillU - Création automatique des utilisateurs AD depuis ListeRHCollaborateurs.csv               #
#   (filtre Societe = BillU uniquement | suppression protection désactivée)                         #
#                                                                                                    #
######################################################################################################

$FilePath = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)

### Paramètre(s) à modifier
$File = "$FilePath\s01-a02-BillU-ListeRHCollaborateurs.csv"

### Table de correspondance Departement CSV --> OU Active Directory
$OUMap = @{
    "Développement logiciel"              = "Developpement"
    "Département Juridique"               = "Juridique"
    "Finance et Comptabilité"             = "Comptabilité"
    "Service Commercial"                  = "Commercial"
    "Communication et Relations publiques"= "Communication"
    "Direction"                           = "Direction/Qualité/Recrutement"
    "Service recrutement"                 = "Direction/Qualité/Recrutement"
    "QHSE"                                = "Direction/Qualité/Recrutement"
    "DSI"                                 = "DSI"
}

### Main program
Clear-Host

If (-not(Get-Module -Name activedirectory)) {
    Import-Module activedirectory
}

# Import du CSV (séparateur virgule, encodage UTF-8 pour les accents)
$Users    = Import-Csv -Path $File -Delimiter "," -Encoding UTF8
$ADUsers  = Get-ADUser -Filter * -Properties SamAccountName
$Count    = 1
$Skipped  = 0
$Created  = 0
$Exists   = 0

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "   BillU - Création des comptes utilisateurs Active Directory" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Foreach ($User in $Users) {

    # --- Filtrage : on ne traite que les employés BillU ---
    If ($User.Societe -ne "BillU") {
        Write-Host "[ IGNORÉ ] $($User.Prenom) $($User.Nom) (Société : $($User.Societe))" -ForegroundColor DarkGray
        $Skipped++
        $Count++
        Continue
    }

    Write-Progress -Activity "Création des utilisateurs BillU dans l'AD" `
                   -Status "Traitement de $($User.Prenom) $($User.Nom)" `
                   -PercentComplete ($Count / $Users.Length * 100)

    # --- Construction des attributs ---

    # Nettoyage des prénoms/noms (suppression accents pour SamAccountName)
    $PrenomClean = $User.Prenom `
        -replace '[àâä]','a' -replace '[éèêë]','e' -replace '[îï]','i' `
        -replace '[ôö]','o'  -replace '[ùûü]','u'  -replace '[ç]','c'  `
        -replace '[ÀÂÄ]','A' -replace '[ÉÈÊË]','E' -replace '[ÎÏ]','I' `
        -replace '[ÔÖ]','O'  -replace '[ÙÛÜ]','U'  -replace '[Ç]','C'  `
        -replace "[-' ]",''

    $NomClean = $User.Nom `
        -replace '[àâä]','a' -replace '[éèêë]','e' -replace '[îï]','i' `
        -replace '[ôö]','o'  -replace '[ùûü]','u'  -replace '[ç]','c'  `
        -replace '[ÀÂÄ]','A' -replace '[ÉÈÊË]','E' -replace '[ÎÏ]','I' `
        -replace '[ÔÖ]','O'  -replace '[ÙÛÜ]','U'  -replace '[Ç]','C'  `
        -replace "[-' ]",''

    $Name              = "$($User.Nom) $($User.Prenom)"
    $DisplayName       = "$($User.Nom) $($User.Prenom)"
    $SamAccountName    = ($PrenomClean.Substring(0,1).ToLower() + $NomClean.ToLower()).Substring(0, [Math]::Min(20, ($PrenomClean.Substring(0,1).ToLower() + $NomClean.ToLower()).Length))
    $UserPrincipalName = $SamAccountName + "@" + (Get-ADDomain).Forest
    $GivenName         = $User.Prenom
    $Surname           = $User.Nom
    $EmailAddress      = $UserPrincipalName
    $Department        = $User.Departement
    $Title             = $User.fonction
    $Company           = "BillU"

    # Téléphone fixe (ignorer les tirets "-")
    If ($User."Telephone fixe" -ne "-" -and $User."Telephone fixe" -ne "") {
        $OfficePhone = $User."Telephone fixe"
    } Else {
        $OfficePhone = $null
    }

    # Téléphone mobile
    If ($User."Telephone portable" -ne "-" -and $User."Telephone portable" -ne "") {
        $MobilePhone = $User."Telephone portable"
    } Else {
        $MobilePhone = $null
    }

    # --- Résolution de l'OU cible ---
    $OUName = $OUMap[$User.Departement]

    If (-not $OUName) {
        Write-Host "[ ATTENTION ] Département inconnu '$($User.Departement)' pour $($User.Prenom) $($User.Nom) — utilisateur ignoré." -ForegroundColor Yellow
        $Skipped++
        $Count++
        Continue
    }

    $Path = "ou=$OUName,ou=BU-Users,dc=BillU,dc=lan"

    # --- Création ou détection doublon ---
    If (($ADUsers | Where-Object { $_.SamAccountName -eq $SamAccountName }) -eq $null) {

        Try {
            $Params = @{
                Name                  = $Name
                DisplayName           = $DisplayName
                SamAccountName        = $SamAccountName
                UserPrincipalName     = $UserPrincipalName
                GivenName             = $GivenName
                Surname               = $Surname
                EmailAddress          = $EmailAddress
                Path                  = $Path
                AccountPassword       = (ConvertTo-SecureString -AsPlainText "Azerty1*" -Force)
                Enabled               = $True
                ChangePasswordAtLogon = $True
                OtherAttributes       = @{
                    Company    = $Company
                    Department = $Department
                    Title      = $Title
                }
            }

            # Ajout du téléphone fixe si disponible
            If ($OfficePhone) { $Params["OfficePhone"] = $OfficePhone }

            # Ajout du mobile si disponible
            If ($MobilePhone) { $Params["MobilePhone"] = $MobilePhone }

            New-ADUser @Params

            # Désactivation de la protection contre la suppression accidentelle
            Set-ADObject -Identity (Get-ADUser $SamAccountName) -ProtectedFromAccidentalDeletion $False

            Write-Host "[ CRÉÉ     ] $SamAccountName — $($User.Prenom) $($User.Nom) → OU: $OUName" -ForegroundColor Green
            $Created++
        }
        Catch {
            Write-Host "[ ERREUR   ] Impossible de créer $SamAccountName : $_" -ForegroundColor Red
        }
    }
    Else {
        Write-Host "[ EXISTANT ] $SamAccountName ($($User.Prenom) $($User.Nom)) existe déjà." -ForegroundColor Black -BackgroundColor Yellow
        $Exists++
    }

    $Count++
    Start-Sleep -Milliseconds 100
}

# --- Résumé final ---
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "   Résumé de l'exécution" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Comptes créés       : $Created" -ForegroundColor Green
Write-Host "  Comptes existants   : $Exists"  -ForegroundColor Yellow
Write-Host "  Lignes ignorées     : $Skipped" -ForegroundColor DarkGray
Write-Host "  Total traité        : $($Count - 1)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
