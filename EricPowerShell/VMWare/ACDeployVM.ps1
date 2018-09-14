#########################################################################################
## Much borrowed from http://communities.vmware.com/thread/315193?start=15&tstart=0	#
##											#
##											#
##											#
##											#
#########################################################################################

# Variables
$vCenter = 'NameOfvCenterHere'
$Datastore = 'DataStoreLocationHere'
$VM = 'NameOfNewVMHere'
$ResourcePool = 'NameOfClusterHere/NameOfHost'
$ISO = '[PathHere] Path/ToISOHere'
$DiskSize = 'DiskSizeInGB'
$MEM = 'MemoryInGB'
$CPUs = 'TotalCPUs'

Connect-VIServer $vCenter

	
	New-VM -name $VM -resourcepool $resourcepool -DiskGB $DiskSize -memoryGB $MEM -numcpu $CPUs -guestID "winLonghorn64Guest" -datastore $datastore -version v8 -DiskStorageFormat thin -runasync
	start-sleep -s 5
	New-CDDrive -VM $vm -ISOPath $ISO -StartConnected:$true -Confirm:$false
	$value = "10000"
	$vm = Get-VM $vm | Get-View
	$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
	$vmConfigSpec.BootOptions = New-Object VMware.Vim.VirtualMachineBootOptions
	$vmConfigSpec.BootOptions.BootDelay = $value
	$vm.ReconfigVM_Task($vmConfigSpec)

    Start-vm -vm $vm.name
