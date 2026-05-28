######################################################################################################
#                                                                                                    #
#   BillU - Installation et configuration automatique du rôle AD DS                                 #
#   Windows Server Core - Ajout d'un contrôleur de domaine supplémentaire                           #
#                                                                                                    #
#   Usage : .\Install-ADDS.ps1 -ConfigFile ".\config.json"                                          #
#                                                                                                    #
######################################################################################################

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $True)]
    [string]$ConfigFile
)

#region ── Fonctions utilitaires ────────────────────────────────────────────────

Function Write-Log {
    Param(
        [string]$Message,
        [ValidateSet("INFO","SUCCESS","WARNING","ERROR")]
        [string]$Level = "INFO"
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Colors = @{
        "INFO"    = "Cyan"
        "SUCCESS" = "Green"
        "WARNING" = "Yellow"
        "ERROR"   = "Red"
    }
    Write-Host "[$Timestamp] [$Level] $Message" -ForegroundColor $Colors[$Level]

    # Écriture dans un fichier log
    $LogFile = "$PSScriptRoot\Install-ADDS_$(Get-Date -Format 'yyyyMMdd').log"
    "[$Timestamp] [$Level] $Message" | Out-File -FilePath $LogFile -Append -Encoding UTF8
}

Function Exit-OnError {
    Param([string]$Message)
    Write-Log $Message "ERROR"
    Exit 1
}

#endregion

#region ── Bannière ─────────────────────────────────────────────────────────────

Clear-Host
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║     BillU - Installation automatique AD DS / Windows Core    ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

#endregion

#region ── Étape 1 : Lecture du fichier de configuration ────────────────────────

Write-Log "Chargement du fichier de configuration : $ConfigFile" "INFO"

If (-not (Test-Path $ConfigFile)) {
    Exit-OnError "Fichier de configuration introuvable : $ConfigFile"
}

Try {
    $Config = Get-Content -Path $ConfigFile -Raw -Encoding UTF8 | ConvertFrom-Json
} Catch {
    Exit-OnError "Impossible de lire le fichier JSON : $_"
}

# Vérification des clés obligatoires
$RequiredKeys = @("ServerName","IPAddress","PrefixLength","DefaultGateway","DNSServer","DomainName","NetbiosName","SiteName","DatabasePath","LogPath","SysvolPath")
Foreach ($Key in $RequiredKeys) {
    If (-not $Config.PSObject.Properties[$Key]) {
        Exit-OnError "Clé manquante dans le fichier de config : $Key"
    }
}

Write-Log "Configuration chargée avec succès." "SUCCESS"
Write-Host ""
Write-Host "  ┌─────────────────────────────────────────────┐" -ForegroundColor DarkCyan
Write-Host "  │  Paramètres chargés                         │" -ForegroundColor DarkCyan
Write-Host "  ├─────────────────────────────────────────────┤" -ForegroundColor DarkCyan
Write-Host "  │  Serveur      : $($Config.ServerName.PadRight(28))│" -ForegroundColor White
Write-Host "  │  IP statique  : $($Config.IPAddress.PadRight(28))│" -ForegroundColor White
Write-Host "  │  Passerelle   : $($Config.DefaultGateway.PadRight(28))│" -ForegroundColor White
Write-Host "  │  DNS          : $($Config.DNSServer.PadRight(28))│" -ForegroundColor White
Write-Host "  │  Domaine      : $($Config.DomainName.PadRight(28))│" -ForegroundColor White
Write-Host "  └─────────────────────────────────────────────┘" -ForegroundColor DarkCyan
Write-Host ""

#endregion

#region ── Étape 2 : Vérification des droits administrateur ────────────────────

Write-Log "Vérification des droits administrateur..." "INFO"

$CurrentUser = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
If (-not $CurrentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Exit-OnError "Ce script doit être exécuté en tant qu'Administrateur."
}

Write-Log "Droits administrateur confirmés." "SUCCESS"

#endregion

#region ── Étape 3 : Renommage du serveur ───────────────────────────────────────

$CurrentName = $env:COMPUTERNAME

If ($CurrentName -ne $Config.ServerName) {
    Write-Log "Renommage du serveur : '$CurrentName' → '$($Config.ServerName)'" "WARNING"
    Try {
        Rename-Computer -NewName $Config.ServerName -Force -ErrorAction Stop
        Write-Log "Serveur renommé. Un redémarrage sera effectué après la configuration réseau." "SUCCESS"
        $NeedsReboot = $True
    } Catch {
        Exit-OnError "Échec du renommage : $_"
    }
} Else {
    Write-Log "Nom du serveur déjà correct : $CurrentName" "INFO"
    $NeedsReboot = $False
}

#endregion

#region ── Étape 4 : Configuration réseau (IP statique + DNS) ──────────────────

Write-Log "Configuration de l'interface réseau..." "INFO"

# Récupération de l'interface active
$NetAdapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1

If (-not $NetAdapter) {
    Exit-OnError "Aucune interface réseau active trouvée."
}

Write-Log "Interface réseau détectée : $($NetAdapter.Name) [$($NetAdapter.InterfaceDescription)]" "INFO"

Try {
    # Suppression des adresses IP existantes pour éviter les conflits
    $ExistingIPs = Get-NetIPAddress -InterfaceIndex $NetAdapter.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
    If ($ExistingIPs) {
        $ExistingIPs | Remove-NetIPAddress -Confirm:$False -ErrorAction SilentlyContinue
    }

    # Suppression de l'ancienne passerelle
    $ExistingRoute = Get-NetRoute -InterfaceIndex $NetAdapter.ifIndex -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue
    If ($ExistingRoute) {
        $ExistingRoute | Remove-NetRoute -Confirm:$False -ErrorAction SilentlyContinue
    }

    # Application de la nouvelle IP statique + passerelle
    New-NetIPAddress `
        -InterfaceIndex  $NetAdapter.ifIndex `
        -IPAddress       $Config.IPAddress `
        -PrefixLength    $Config.PrefixLength `
        -DefaultGateway  $Config.DefaultGateway `
        -ErrorAction Stop | Out-Null

    # Configuration du DNS (pointe vers le DC principal)
    Set-DnsClientServerAddress `
        -InterfaceIndex $NetAdapter.ifIndex `
        -ServerAddresses $Config.DNSServer `
        -ErrorAction Stop

    Write-Log "Réseau configuré : IP=$($Config.IPAddress)/$($Config.PrefixLength) | GW=$($Config.DefaultGateway) | DNS=$($Config.DNSServer)" "SUCCESS"

} Catch {
    Exit-OnError "Échec de la configuration réseau : $_"
}

#endregion

#region ── Étape 5 : Test de connectivité vers le DC principal ──────────────────

Write-Log "Test de connectivité vers le DNS/DC principal ($($Config.DNSServer))..." "INFO"

$PingResult = Test-Connection -ComputerName $Config.DNSServer -Count 2 -Quiet

If (-not $PingResult) {
    Exit-OnError "Impossible de joindre le DC principal ($($Config.DNSServer)). Vérifiez le réseau."
}

Write-Log "DC principal joignable." "SUCCESS"

#endregion

#region ── Étape 6 : Installation du rôle AD DS ────────────────────────────────

Write-Log "Installation du rôle AD-Domain-Services..." "INFO"

$Feature = Get-WindowsFeature -Name AD-Domain-Services

If ($Feature.InstallState -eq "Installed") {
    Write-Log "Le rôle AD DS est déjà installé." "INFO"
} Else {
    Try {
        Install-WindowsFeature `
            -Name AD-Domain-Services `
            -IncludeManagementTools `
            -ErrorAction Stop | Out-Null

        Write-Log "Rôle AD DS installé avec succès." "SUCCESS"
    } Catch {
        Exit-OnError "Échec de l'installation du rôle AD DS : $_"
    }
}

#endregion

#region ── Étape 7 : Promotion en contrôleur de domaine supplémentaire ──────────

Write-Log "Promotion en contrôleur de domaine supplémentaire pour : $($Config.DomainName)" "INFO"
Write-Log "Entrez les credentials d'un compte Administrateur du domaine." "WARNING"

# Demande des credentials du domaine (compte ayant le droit de promouvoir un DC)
$DomainCredential = Get-Credential -Message "Compte Administrateur du domaine $($Config.DomainName)"

If (-not $DomainCredential) {
    Exit-OnError "Aucun credential fourni. Abandon."
}

# Demande du mot de passe DSRM (Directory Services Restore Mode)
Write-Log "Définissez le mot de passe DSRM (Directory Services Restore Mode)." "WARNING"
$SafeModePassword = Read-Host -Prompt "Mot de passe DSRM" -AsSecureString

Try {
    Install-ADDSDomainController `
        -DomainName                    $Config.DomainName `
        -SiteName                      $Config.SiteName `
        -DatabasePath                  $Config.DatabasePath `
        -LogPath                       $Config.LogPath `
        -SysvolPath                    $Config.SysvolPath `
        -Credential                    $DomainCredential `
        -SafeModeAdministratorPassword $SafeModePassword `
        -InstallDns:$True `
        -NoGlobalCatalog:$False `
        -Force:$True `
        -NoRebootOnCompletion:$False `
        -ErrorAction Stop

    Write-Log "Promotion réussie ! Le serveur va redémarrer automatiquement." "SUCCESS"

} Catch {
    Exit-OnError "Échec de la promotion en DC : $_"
}

#endregion

######################################################################################################
#   Après le redémarrage, le serveur sera contrôleur de domaine supplémentaire de BillU.lan         #
######################################################################################################
