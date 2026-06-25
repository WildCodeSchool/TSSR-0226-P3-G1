Import-Module ActiveDirectory

  

$SearchBase = "OU=BU_Users,DC=BillU,DC=lan"

$BackupPath = "C:\Scripts\backup_users_avant_modification.csv"

  

Get-ADUser -Filter * -SearchBase $SearchBase -Properties Title,Department,Mail,Description,Enabled |

Select-Object SamAccountName,Name,Title,Department,Mail,Description,Enabled |

Export-Csv $BackupPath -NoTypeInformation -Encoding UTF8 -Delimiter ";"

  

Write-Host "Sauvegarde créée : $BackupPath" -ForegroundColor Green
