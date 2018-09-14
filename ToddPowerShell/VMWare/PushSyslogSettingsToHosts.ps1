#The following sets the syslog to  tcp://10.76.193.4:1514
# You must first connect to the vcenter hosting these servers. 
# For Example: Connect-VIServer -Server usssusvc010 -User nasa\ssith_adm -Password XXXXXXXXXX
# You must also have powercli loaded

$Catalog = GC "vmhosts.txt"
ForEach($Machine in $Catalog) 
{ 
Set-VMHostSysLogServer -SysLogServer 'tcp://10.76.193.4:1514' -VMHost $Machine
Write-Host $Machine 
}