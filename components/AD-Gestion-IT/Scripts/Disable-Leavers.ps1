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

  

        # Désactivation du compte

        Disable-ADAccount -Identity $Sam

  

        # Retrait des groupes sauf Domain Users

        foreach ($GroupDN in $ADUser.MemberOf) {

            $Group = Get-ADGroup -Identity $GroupDN

  

            if ($Group.Name -ne "Domain Users") {

                Remove-ADGroupMember -Identity $Group -Members $Sam -Confirm:$false

            }

        }

  

        # Ajout d'une trace dans la description

        Set-ADUser -Identity $Sam -Description "Compte desactive suite au depart du collaborateur - Date : $DateDepart - Ticket : $Ticket"

  

        # Déplacement dans l'OU d'archive

        Move-ADObject -Identity $ADUser.DistinguishedName -TargetPath $ArchiveOU

  

        Add-Content -Path $LogPath -Value "[$(Get-Date)] OK : $Sam desactive, groupes retires, deplace dans $ArchiveOU"

  

        Write-Host "Compte $Sam traite avec succes" -ForegroundColor Green

    }

    catch {

        Add-Content -Path $LogPath -Value "[$(Get-Date)] ERREUR : $Sam - $($_.Exception.Message)"

        Write-Host "Erreur avec le compte $Sam : $($_.Exception.Message)" -ForegroundColor Red

    }

}
