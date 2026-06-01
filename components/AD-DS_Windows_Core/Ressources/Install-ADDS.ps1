######################################################################################################
#   BillU - Installation et configuration automatique du role AD DS                                 #
#   Windows Server Core - Ajout d'un controleur de domaine supplementaire                           #
#   Usage : .\Install-ADDS.ps1 -ConfigFile ".\config.json"                                          #
######################################################################################################

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $True)]
    [string]$ConfigFile
)

# Fonction log
Function Write-Log {
    Param(
        [string]$Message,
        [ValidateSet("INFO","SUCCESS","WARNING","ERROR")]
        [string]$Level = "INFO"
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Colors = @{ "INFO"="Cyan"; "SUCCESS"="Green"; "WARNING"="Yellow"; "ERROR"="Red" }
    Write-Host "[$Timestamp] [$Level] $Message" -ForegroundColor $Colors[$Level]
    $LogFile = "$PSScriptRoot\Install-ADDS_$(Get-Date -Format 'yyyyMMdd').log"
    "[$Timestamp] [$Level] $Message" | Out-File -FilePath $LogFile -Append -Encoding UTF8
}

Function Exit-OnError {
    Param([string]$Message)
    Write-Log $Message "ERROR"
    Exit 1
}

Clear-Host
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  BillU - Installation automatique AD DS        " -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# Etape 1 : Lecture du fichier de configuration
Write-Log "Chargement du fichier de configuration : $ConfigFile" "INFO"

If (-not (Test-Path $ConfigFile)) {
    Exit-OnError "Fichier de configuration introuvable : $ConfigFile"
}

Try {
    $RawJson = [System.IO.File]::ReadAllText($ConfigFile, [System.Text.Encoding]::UTF8)
    $Config  = $RawJson | ConvertFrom-Json
} Catch {
    Exit-OnError "Impossible de lire le fichier JSON : $_"
}

# Verification des cles obligatoires
$RequiredKeys = @("ServerName","IPAddress","PrefixLength","DefaultGateway","DNSServer","DomainName","NetbiosName","SiteName","DatabasePath","LogPath","SysvolPath")
Foreach ($Key in $RequiredKeys) {
    If (-not $Config.PSObject.Properties[$Key]) {
        Exit-OnError "Cle manquante dans le fichier de config : $Key"
    }
    If ([string]::IsNullOrWhiteSpace($Config.$Key)) {
        Exit-OnError "La valeur de '$Key' est vide dans le fichier de config."
    }
}

Write-Log "Configuration chargee avec succes." "SUCCESS"
Write-Log "  Serveur     : $($Config.ServerName)" "INFO"
Write-Log "  IP statique : $($Config.IPAddress)" "INFO"
Write-Log "  Passerelle  : $($Config.DefaultGateway)" "INFO"
Write-Log "  DNS         : $($Config.DNSServer)" "INFO"
Write-Log "  Domaine     : $($Config.DomainName)" "INFO"

# Etape 2 : Verification des droits administrateur
Write-Log "Verification des droits administrateur..." "INFO"
$CurrentUser = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
If (-not $CurrentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Exit-OnError "Ce script doit etre execute en tant qu'Administrateur."
}
Write-Log "Droits administrateur confirmes." "SUCCESS"

# Etape 3 : Renommage du serveur
$CurrentName = $env:COMPUTERNAME
If ($CurrentName -ne $Config.ServerName) {
    Write-Log "Renommage du serveur : '$CurrentName' -> '$($Config.ServerName)'" "WARNING"
    Try {
        Rename-Computer -NewName $Config.ServerName -Force -ErrorAction Stop
        Write-Log "Serveur renomme avec succes." "SUCCESS"
    } Catch {
        Exit-OnError "Echec du renommage : $_"
    }
} Else {
    Write-Log "Nom du serveur deja correct : $CurrentName" "INFO"
}

# Etape 4 : Configuration reseau
Write-Log "Configuration de l'interface reseau..." "INFO"
$NetAdapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
If (-not $NetAdapter) {
    Exit-OnError "Aucune interface reseau active trouvee."
}
Write-Log "Interface detectee : $($NetAdapter.Name)" "INFO"

Try {
    $ExistingIPs = Get-NetIPAddress -InterfaceIndex $NetAdapter.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
    If ($ExistingIPs) { $ExistingIPs | Remove-NetIPAddress -Confirm:$False -ErrorAction SilentlyContinue }

    $ExistingRoute = Get-NetRoute -InterfaceIndex $NetAdapter.ifIndex -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue
    If ($ExistingRoute) { $ExistingRoute | Remove-NetRoute -Confirm:$False -ErrorAction SilentlyContinue }

    New-NetIPAddress `
        -InterfaceIndex $NetAdapter.ifIndex `
        -IPAddress      $Config.IPAddress `
        -PrefixLength   $Config.PrefixLength `
        -DefaultGateway $Config.DefaultGateway `
        -ErrorAction Stop | Out-Null

    Set-DnsClientServerAddress `
        -InterfaceIndex  $NetAdapter.ifIndex `
        -ServerAddresses $Config.DNSServer `
        -ErrorAction Stop

    Write-Log "Reseau configure avec succes." "SUCCESS"
} Catch {
    Exit-OnError "Echec de la configuration reseau : $_"
}

# Etape 5 : Test de connectivite
Write-Log "Test de connectivite vers $($Config.DNSServer)..." "INFO"
$PingResult = Test-Connection -ComputerName $Config.DNSServer -Count 2 -Quiet
If (-not $PingResult) {
    Exit-OnError "Impossible de joindre le DC principal ($($Config.DNSServer))."
}
Write-Log "DC principal joignable." "SUCCESS"

# Etape 6 : Installation du role AD DS
Write-Log "Installation du role AD-Domain-Services..." "INFO"
$Feature = Get-WindowsFeature -Name AD-Domain-Services
If ($Feature.InstallState -eq "Installed") {
    Write-Log "Le role AD DS est deja installe." "INFO"
} Else {
    Try {
        Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -ErrorAction Stop | Out-Null
        Write-Log "Role AD DS installe avec succes." "SUCCESS"
    } Catch {
        Exit-OnError "Echec de l'installation du role AD DS : $_"
    }
}

# Etape 7 : Promotion en controleur de domaine
Write-Log "Promotion en DC supplementaire pour : $($Config.DomainName)" "INFO"
Write-Log "Entrez les credentials d'un compte Administrateur du domaine." "WARNING"
$DomainCredential = Get-Credential -Message "Compte Administrateur du domaine $($Config.DomainName)"
If (-not $DomainCredential) { Exit-OnError "Aucun credential fourni. Abandon." }

Write-Log "Definissez le mot de passe DSRM." "WARNING"
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

    Write-Log "Promotion reussie ! Redemarrage en cours..." "SUCCESS"
} Catch {
    Exit-OnError "Echec de la promotion en DC : $_"
}
