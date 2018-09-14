###############################################################################################
##
## Get-VM will get list of all VM's from txt file
##
##
################################################################################

$VMs = "C:\Temp\EpiRocATOSVMs.txt"
$ExportFile = "C:\temp\ExportVMInfo.csv"

get-Viserver @('usssusvc010','usssusvc001';'ssisusvc0005','ssdsbrvc0001');

get-vm (Get-Content $VMs) | Select-Object Name,NumCpu,MemoryGB,ProvisionedSpaceGB | Export-Csv $ExportFile -NoTypeInformation

