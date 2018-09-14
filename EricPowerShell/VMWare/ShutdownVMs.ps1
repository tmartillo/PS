####
## PoSH from http://www.virtu-al.net/2010/01/06/powercli-shutdown-your-virtual-infrastructure/
## PoSH to shutdown VM's on specidied Datacenter
## Variable is $DataCenter place the datacenter to gather powered on VM's and shuutdown
##
####
$Datacenter="Texas-Grand Prairie 2"

# For each of the VMs on the ESX hosts
Foreach ($VM in ( Get-Datacenter "$Datacenter") | Get-VM | where {$_.powerstate -eq "PoweredON"}){
    # Shutdown the guest cleanly
    $VM | Shutdown-VMGuest -Confirm:$false
}