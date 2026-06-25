Import-Module ActiveDirectory

  

$SearchBase = "OU=BU_Users,DC=BillU,DC=lan"

$ExportPath = "C:\Scripts\feminisation_postes.csv"

  

Get-ADUser -Filter * -SearchBase $SearchBase -Properties Title,Department,Mail |

Select-Object SamAccountName,Name,Title,Department,Mail,@{Name="PosteFeminise";Expression={""}} |

Export-Csv $ExportPath -NoTypeInformation -Encoding UTF8 -Delimiter ";"

  

Write-Host "Export terminé : $ExportPath" -ForegroundColor Green
