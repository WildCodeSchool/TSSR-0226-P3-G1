<#
.SYNOPSIS
    Déplace automatiquement les ordinateurs AD dans les bonnes OU
    en fonction de leur nom (préfixe) et/ou de la valeur d'un attribut AD.

.DESCRIPTION
    Le script parcourt les ordinateurs présents dans une OU "source"
    (par ex. l'OU Computers par défaut) et les déplace vers l'OU cible
    définie dans la table de correspondance ($RulesByName et $RulesByAttribute).

    Deux modes de correspondance, cumulables :
      1. Par nom de machine (préfixe, ex: "PC-PARIS*"  -> OU Paris)
      2. Par valeur d'un attribut AD (ex: description, location, ou attribut personnalisé)

    Toutes les actions sont journalisées dans un fichier de log.

.NOTES
    Auteur  : (à compléter)
    Prérequis : Module ActiveDirectory (RSAT), droits de déplacement d'objets,
                exécution sur un serveur membre ou DC.
    Tester d'abord avec -WhatIf (variable $TestMode ci-dessous).
#>

# ============================================================
# CONFIGURATION
# ============================================================

Import-Module ActiveDirectory -ErrorAction Stop

# Mode test : $true = simulation (aucun déplacement réel), $false = production
$TestMode = $true

# OU source à surveiller : conteneur par défaut où atterrissent
# les machines jointes au domaine BillU.lan
$SourceOU = "CN=Computers,DC=BillU,DC=lan"

# Fichier de log
$LogDir  = "C:\Scripts\Logs"
$LogFile = Join-Path $LogDir ("MoveComputers_{0}.log" -f (Get-Date -Format "yyyy-MM-dd"))

# ------------------------------------------------------------
# Règle 1 : correspondance par NOM de machine (préfixe -> OU cible)
# ------------------------------------------------------------
# OU cibles disponibles dans la forêt BillU.lan :
#   - OU=Postes_Utilisateurs,OU=BU_Computers,DC=BillU,DC=lan
#   - OU=Serveurs,OU=BU_Computers,DC=BillU,DC=lan
#   - OU=Computers_Admins,OU=BU_Admins,DC=BillU,DC=lan
#
# >>> Convention de nommage BillU.lan <<<
#   BV-*  = serveurs
#   PC-*  = postes utilisateurs
#   ADM-* = machines d'administration (optionnel, supprime la ligne si inutilisé)
$RulesByName = @{
    "BV-"  = "OU=Serveurs,OU=BU_Computers,DC=BillU,DC=lan"
    "PC-"  = "OU=Postes_Utilisateurs,OU=BU_Computers,DC=BillU,DC=lan"
    "ADM-" = "OU=Computers_Admins,OU=BU_Admins,DC=BillU,DC=lan"
}

# ------------------------------------------------------------
# Règle 2 : correspondance par ATTRIBUT AD (valeur -> OU cible)
# ------------------------------------------------------------
# Attribut à inspecter (ex: "description", "location", "departmentNumber"...)
# Renseigne par ex. "Serveur", "Admin" ou "Poste" dans la description
# de l'objet ordinateur pour piloter son placement.
$AttributeName = "description"

$RulesByAttribute = @{
    "Serveur" = "OU=Serveurs,OU=BU_Computers,DC=BillU,DC=lan"
    "Admin"   = "OU=Computers_Admins,OU=BU_Admins,DC=BillU,DC=lan"
    "Poste"   = "OU=Postes_Utilisateurs,OU=BU_Computers,DC=BillU,DC=lan"
}

# Priorité : "Name", "Attribute" ou "AttributeFirst"
# -> détermine quelle règle gagne si les deux correspondent
$Priority = "Name"

# ============================================================
# FONCTIONS
# ============================================================

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    if (-not (Test-Path $LogDir)) { New-Item -Path $LogDir -ItemType Directory -Force | Out-Null }
    $line = "{0} [{1}] {2}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Level, $Message
    Add-Content -Path $LogFile -Value $line
    Write-Host $line
}

function Get-TargetOUByName {
    param([string]$ComputerName)
    foreach ($prefix in $RulesByName.Keys) {
        if ($ComputerName -like "$prefix*") { return $RulesByName[$prefix] }
    }
    return $null
}

function Get-TargetOUByAttribute {
    param($Computer)
    $value = $Computer.$AttributeName
    if ([string]::IsNullOrWhiteSpace($value)) { return $null }
    foreach ($key in $RulesByAttribute.Keys) {
        if ($value -like "*$key*") { return $RulesByAttribute[$key] }
    }
    return $null
}

# ============================================================
# TRAITEMENT
# ============================================================

Write-Log "===== Début du traitement (TestMode = $TestMode) ====="

try {
    $computers = Get-ADComputer -SearchBase $SourceOU -SearchScope OneLevel `
                 -Filter * -Properties $AttributeName
}
catch {
    Write-Log "Impossible de lire l'OU source $SourceOU : $_" "ERROR"
    exit 1
}

if (-not $computers) {
    Write-Log "Aucun ordinateur trouvé dans $SourceOU. Fin."
    exit 0
}

$moved = 0; $skipped = 0; $errors = 0

foreach ($computer in $computers) {

    $ouByName = Get-TargetOUByName -ComputerName $computer.Name
    $ouByAttr = Get-TargetOUByAttribute -Computer $computer

    # Choix de l'OU cible selon la priorité configurée
    $targetOU = switch ($Priority) {
        "Name"           { if ($ouByName) { $ouByName } else { $ouByAttr } }
        "Attribute"      { if ($ouByAttr) { $ouByAttr } else { $ouByName } }
        "AttributeFirst" { if ($ouByAttr) { $ouByAttr } else { $ouByName } }
        default          { $ouByName }
    }

    if (-not $targetOU) {
        Write-Log "$($computer.Name) : aucune règle ne correspond, ignoré." "SKIP"
        $skipped++
        continue
    }

    # Vérifier que l'OU cible existe
    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$targetOU'" -ErrorAction SilentlyContinue)) {
        Write-Log "$($computer.Name) : l'OU cible '$targetOU' n'existe pas !" "ERROR"
        $errors++
        continue
    }

    # Déjà au bon endroit ?
    $currentOU = ($computer.DistinguishedName -split ",", 2)[1]
    if ($currentOU -eq $targetOU) {
        Write-Log "$($computer.Name) : déjà dans la bonne OU." "SKIP"
        $skipped++
        continue
    }

    # Déplacement
    try {
        if ($TestMode) {
            Move-ADObject -Identity $computer.DistinguishedName -TargetPath $targetOU -WhatIf
            Write-Log "$($computer.Name) : [SIMULATION] serait déplacé vers $targetOU" "TEST"
        }
        else {
            Move-ADObject -Identity $computer.DistinguishedName -TargetPath $targetOU
            Write-Log "$($computer.Name) : déplacé vers $targetOU" "MOVE"
        }
        $moved++
    }
    catch {
        Write-Log "$($computer.Name) : échec du déplacement -> $_" "ERROR"
        $errors++
    }
}

Write-Log "===== Fin : $moved déplacé(s), $skipped ignoré(s), $errors erreur(s) ====="
