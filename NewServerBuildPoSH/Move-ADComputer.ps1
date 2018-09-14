# Use this to move your new server from the Computers OU into the proper server OU
$server = 'NEWSERVERNAME'

# DC Variables
$acadc = 'ACASCADC002'
$aitdc = 'AITSUSDC0002'
$argdc = 'ARGSARDC0002'
$arodc = 'AROSUSDC001'
$catdc = 'CATSCADC0002'
$jcadc = 'JCASCADC003'
$mcadc = 'MCASCADC0002'
$perdc = 'PERSPEDC001'
SSDSBRDC0005
SSDSBRDC0006
SSISBEDC0011
SSISBRDC0007
$chldc = 'SSISCLDC0001'
$coldc = 'SSISCODC001'
$mexdc = 'SSISMXDC001'
$rhdc = 'SSISUSDC0004'
$ussdc = 'SSISUSDC002'
$tbidc = 'TBISUSDC002'
$utbdc = 'UTBSUSDC002'
$utydc = 'UTYSUSDC001'
$uumdc = 'SSISUSDC0005'
$vendc = 'VENSVEDC0001'

# Add an OU like $gar as you use this
$ait = "OU=Servers,OU=Auburn Hills,OU=AFS,OU=IT,DC=nasa,DC=group,DC=atlascopco,DC=com" # Auburn Hills
$gar = "OU=Servers,OU=Garland,OU=USS,OU=MR,DC=nasa,DC=group,DC=atlascopco,DC=com" # Garland
$com = "OU=Servers,OU=Commerce City,OU=ARO,OU=MR,DC=nasa,DC=group,DC=atlascopco,DC=com" # Commerce City
$per = "OU=Servers,OU=Lima,OU=PER,OU=MR,DC=nasa,DC=group,DC=atlascopco,DC=com" # Lima
$mis = "OU=Servers,OU=Mississauga,OU=MCA,OU=MR,DC=nasa,DC=group,DC=atlascopco,DC=com" # Mississauga
$uum = "OU=Servers,OU=New Hudson,OU=UUM,OU=IT,DC=nasa,DC=group,DC=atlascopco,DC=com"
$chl = "OU=Servers,OU=Santiago,OU=CHL,OU=MR,DC=nasa,DC=group,DC=atlascopco,DC=com" # Chile
$tla = "OU=Servers,OU=Tlalnepantla,OU=MXC,OU=MR,DC=nasa,DC=group,DC=atlascopco,DC=com" # Tlalnepantla
$zac = "OU=Servers,OU=Zacatecas,OU=MXC,OU=MR,DC=nasa,DC=group,DC=atlascopco,DC=com" # Zacatecas

# The following lines perform the move according to the variables used
# Add a new line for each site where you need to move server ad objects if it's not here

Get-ADComputer -Server $USSDC $server | Move-ADObject -Server $USSDC -TargetPath $gar -Confirm:$false -Verbose # This is for Garland Servers
Get-ADComputer -Server $arodc $server | Move-ADObject -Server $ARODC-TargetPath $com -Confirm:$false -Verbose # This is for Denver Servers
Get-ADComputer -Server $mexdc $server | Move-ADObject -Server $mexdc -TargetPath $tla -Confirm:$false -Verbose # This is for Tlalnepantla Servers
Get-ADComputer -Server $aitdc $server | Move-ADObject -Server $aitdc -TargetPath $ait -Confirm:$false -Verbose # This is for Auburn Hills Servers
Get-ADComputer -Server $uumdc $server | Move-ADObject -Server $uumdc -TargetPath $uum -Confirm:$false -Verbose # This is for New Hudson Servers
Get-ADComputer -Server $mexdc $server | Move-ADObject -Server $mexdc -TargetPath $zac -Confirm:$false -Verbose # This is for Zacatecas Servers