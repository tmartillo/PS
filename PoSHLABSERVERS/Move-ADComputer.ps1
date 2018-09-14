# Use this to move your new server from the Computers OU into the proper server OU
$server = 'USSSUSWSUS0001'

# DC Variables
$ussdc = 'SSISUSDC002'

# Add an OU like $gar as you use this
$gar = "OU=Servers,OU=Garland,OU=USS,OU=MR,DC=nasa,DC=group,DC=atlascopco,DC=com" # Garland

# The following lines perform the move according to the variables used
# Add a new line for each site where you need to move server ad objects if it's not here

Get-ADComputer -Server $USSDC $server | Move-ADObject -Server $USSDC -TargetPath $gar -Confirm:$false -Verbose # This is for Garland Servers
