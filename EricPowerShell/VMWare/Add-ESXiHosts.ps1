
## Enter your vCenter here

get-viserver -server usssusvc010.nasa.group.atlascopco.com
 
########################################################################
# Add Multiple Hosts to vCenter
######################################################################## 
 
# Variables
## You can use comma separated names or change to pull from a text file. Your pick.
$ESXiHosts = "usssusesx001.nasa.group.atlascopco.com" , "usssusesx002.nasa.group.atlascopco.com" , "usssusesx003.nasa.group.atlascopco.com"
## Enter the name of a Data Center or Host Cluster
$ESXiLocation = "Garland - USA009"
 
# Start Script
$credentials = Get-Credential -UserName root -Message "Enter the ESXi root password"
 
Foreach ($ESXiHosts in $ESXiHosts) { 
 Add-VMHost -Name $ESXiHosts -Location $ESXiLocation -User $credentials.UserName -Password $credentials.GetNetworkCredential().Password -RunAsync -force
 Write-Host -ForegroundColor GREEN "Adding ESXi host $ESXiHosts to vCenter"
 } 
# End Script 