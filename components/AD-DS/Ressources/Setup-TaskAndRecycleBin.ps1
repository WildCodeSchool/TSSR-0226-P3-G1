<#
.SYNOPSIS
    Script d'installation (à exécuter UNE FOIS en tant qu'administrateur) :
      1. Crée la tâche planifiée qui exécute Move-ComputersToOU.ps1
      2. Active la corbeille Active Directory (Recycle Bin)

.NOTES
    À lancer sur un contrôleur de domaine ou serveur d'administration
    avec un compte membre de "Domain Admins" / "Enterprise Admins"
    (l'activation de la corbeille exige Enterprise Admins).
#>

# ============================================================
# 1. TÂCHE PLANIFIÉE
# ============================================================
# Remarque : la commande historique "AT" est obsolète et supprimée depuis
# Windows Server 2012. On utilise le Planificateur de tâches (équivalent
# moderne), via les cmdlets ScheduledTasks.

$ScriptPath = "C:\Scripts\Move-ComputersToOU.ps1"
$TaskName   = "AD - Deplacement automatique des ordinateurs"

# Compte d'exécution : idéalement un gMSA (Group Managed Service Account)
# avec délégation de déplacement d'objets sur les OU concernées.
# Ici : SYSTEM sur un DC (fonctionne, mais un gMSA est la bonne pratique).

$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""

# Exécution toutes les heures (à adapter : quotidien, toutes les 15 min, etc.)
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Date `
    -RepetitionInterval (New-TimeSpan -Hours 1) `
    -RepetitionDuration ([TimeSpan]::MaxValue)

$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" `
    -LogonType ServiceAccount -RunLevel Highest

$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable `
    -DontStopOnIdleEnd -ExecutionTimeLimit (New-TimeSpan -Minutes 30)

Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger `
    -Principal $principal -Settings $settings -Force

Write-Host "Tâche planifiée '$TaskName' créée." -ForegroundColor Green

# ============================================================
# 2. ACTIVATION DE LA CORBEILLE AD
# ============================================================
# ATTENTION : opération IRRÉVERSIBLE (on ne peut pas désactiver la corbeille).
# Prérequis : niveau fonctionnel de forêt >= Windows Server 2008 R2.

Import-Module ActiveDirectory

$forest = Get-ADForest

# Vérifier si déjà activée
$recycleBin = Get-ADOptionalFeature -Filter 'Name -eq "Recycle Bin Feature"'

if ($recycleBin.EnabledScopes.Count -gt 0) {
    Write-Host "La corbeille AD est déjà activée." -ForegroundColor Yellow
}
else {
    Enable-ADOptionalFeature -Identity 'Recycle Bin Feature' `
        -Scope ForestOrConfigurationSet `
        -Target $forest.Name `
        -Confirm:$false

    Write-Host "Corbeille AD activée pour la forêt $($forest.Name)." -ForegroundColor Green
}

# Bonus : commande pour restaurer un objet supprimé plus tard
# Get-ADObject -Filter 'Name -like "*PC-PARIS-01*"' -IncludeDeletedObjects | Restore-ADObject
