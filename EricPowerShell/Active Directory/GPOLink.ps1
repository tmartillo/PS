##############################################################################
##
##PSScript to extract all OU's with "name" and link a GPO
##
##
##############################################################################

$row=Get-ADOrganizationalUnit -filter 'name -eq "servers"' -searchbase 'DC=nasa,DC=group,DC=atlascopco,DC=com' | `
Select-Object DistinguishedName | Where-Object {$_.DistinguishedName -notlike "*ou=global*" -and `
$_.DistinguishedName -notlike "*ou=disabled*" -and $_.DistinguishedName -notlike "*ou=rock hill*"} `
 | Select-Object -ExpandProperty DistinguishedName

foreach ($OU in $row){
        
         New-GPLink -Name 'SSI GROUP WSUS Server Policy' -Target $OU        
}