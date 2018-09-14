
Disconnect-VIServer * -force -confirm:$false
cls

#=======================================================================================
# Connect to vCenter 
#=======================================================================================

$title = Write-Host "Which vCenter would you like to create the new VM guest?
usssusvc001
ssdsbrvc0001" -ForegroundColor Yellow
$vcserver = Read-Host -Prompt "Please type in the name of the vCenter"
Write-Host "You've chosen $vcserver as the Virtual Center to create your new VM guest." -ForegroundColor Green

# VMware variables
$now = Get-Date

Write-Host "Connecting to $vcserver $now"
Connect-VIServer $vcserver

#=======================================================================================
# Name of the new VM 
#=======================================================================================

$title = Write-Host "What is the name of the new VM guest?" -ForegroundColor Yellow
$VMName = Read-Host -Prompt "Please type in the name of the new VM guest"
Write-Host "You're new VM will be named $VMName." -ForegroundColor Green

#=======================================================================================
# Name of the Cluster
#=======================================================================================

get-cluster | Select Name, @{N="Datacenter";E={Get-Datacenter -cluster $_}} | Sort-Object name | more
$title = Write-Host "Which Cluster would you like to create the new VM guest on?" -ForegroundColor Yellow
$cluster = Read-Host -Prompt "Please type in the name of the Cluster"
Write-Host "You've chosen $cluster as the cluster to create your new VM guest." -Foreground Green

#=======================================================================================
# Name of the DataStore
#=======================================================================================

get-cluster -name $cluster | get-vmhost | get-datastore | where {$_.capacityGB -gt 140} | Sort-Object FreeSpaceGB -descending | more
$title = Write-Host "Which Datastore would you like to use? Choose the DataStore with the largest free space!
 (***Do not choose a local datastore!!!***)" -ForegroundColor Yellow
$Datastore = Read-Host -Prompt "Please type in the name of the Datastore you would like to use"
Write-Host "You're new VM will be added to $Datastore." -ForegroundColor Green

#=======================================================================================
# Name of the VM Template
#=======================================================================================

(get-cluster -name $cluster | get-vmhost) | get-template | select name, @{n='VMTemplate';e={$_.extensiondata.config.files.VmPathName}} | ft -wrap | more
$title = Write-Host "Which VM template would you like to use?" -ForegroundColor Yellow
$VMTemplate = Read-Host -Prompt "Please type in the name of the VM Template you would like to use"
Write-Host "You're new VM will be cloned using the VM Template $VMTemplate." -ForegroundColor Green

#=======================================================================================
# Cloning VM
#=======================================================================================

Write-Host "You're new VM will be cloned using the $VMTemplate, on $datastore, in the $cluster Cluster, and will be called $vmname" -ForegroundColor Green
try {$vm = New-VM -resourcepool $cluster -Name $VMName -Template $VMTemplate -Datastore $datastore -confirm -ErrorAction:Stop
Start-vm -vm $vmname.name        
}

catch

{
        Write-Host "An error ocurred during template clone operation:"
 
        # output all exception information
        $_ | fl
 
        Write-Host "Cleaning up ..."
 
        # clean up and exit
        $exists = Get-VM -Name $name -ErrorAction SilentlyContinue
        If ($Exists){
                Remove-VM -VM $exists -DeletePermanently
        }
        return
}

