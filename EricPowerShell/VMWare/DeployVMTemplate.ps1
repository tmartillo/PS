#########################################################################################
## Much borrowed from http://communities.vmware.com/thread/315193?start=15&tstart=0	#
##											#
##											#
##											#
##											#
#########################################################################################

#$File = Import-Csv -path 'C:\Install\PowerShell\Deploy VM\Deploy DCs\NorthAmerica\DeployDCs.csv' #Note: Path where you put your CSV file to import.

# Virtual Center Details
$vCenter = 'usssusis019'

Connect-VIServer $vCenter

foreach ($vm in $file){
	$Datastore = Get-Datastore $vm.datastore
	$ResourcePool = $vm.cluster
	$ISO = $vm.iso
	New-VM -name $vm.name -resourcepool $resourcepool -DiskGB 60,40 -memoryGB 8 -numcpu 2 -guestID "winLonghorn64Guest" -datastore $datastore -version v8 -DiskStorageFormat thin -runasync
	start-sleep -s 5
	New-CDDrive -VM $vm.name -ISOPath $ISO -StartConnected:$true -Confirm:$false
	$value = "10000"
	$vm = Get-VM $vm.name | Get-View
	$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
	$vmConfigSpec.BootOptions = New-Object VMware.Vim.VirtualMachineBootOptions
	$vmConfigSpec.BootOptions.BootDelay = $value
	$vm.ReconfigVM_Task($vmConfigSpec)

    Start-vm -vm $vm.name
}
