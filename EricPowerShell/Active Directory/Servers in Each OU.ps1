
Get-ADComputer -Filter {OperatingSystem -Like "Windows *Server*"} -Property * -searchbase 'DC=nasa,DC=group,DC=atlascopco,DC=com' | ? {$_.DistinguishedName -notlike "*ou=global*" -and $_.DistinguishedName -notlike "*ou=disabled*" -and $_.DistinguishedName -notlike "*ou=rock hill*" -and $_.DistinguishedName -notlike "*ou=TBI*" -and $_.DistinguishedName -notlike "*ou=Domain Controllers*" -and $_.DistinguishedName -notlike "*ou=computers*"} | Format-Table Name,OperatingSystem -Wrap -Auto





Get-ADComputer -Filter {OperatingSystem -Like "Windows *Server*"} -Property * -searchbase 'DC=nasa,DC=group,DC=atlascopco,DC=com' | Sort-Object name | Format-Table Name, IPv4Address, OperatingSystem -Wrap -Auto