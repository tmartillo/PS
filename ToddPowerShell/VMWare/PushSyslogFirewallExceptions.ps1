#The following sets the syslog to  tcp://10.76.193.4:1514
# You must first connect to the vcenter hosting these servers. 
# For Example: Connect-VIServer -Server usssusvc010 -User nasa\ssith_adm -Password XXXXXXXXXX
# You must also have powercli loaded

$Catalog = GC "vmhosts.txt"
ForEach($Machine in $Catalog) 
{ 
    $ftpFirewallExceptions = Get-VMHostFirewallException -VMHost "$Machine" | where {$_.Name.StartsWith('syslog')}
    $ftpFirewallExceptions | Set-VMHostFirewallException -Enabled $true
    Write-Host $Machine 
}