##################################################################
##                                                              ##
## the following scipt will add a paravirtual scis controller   ##
##                                                              ##
##################################################################


### Get VM/Disk Count/Datastore information

$vmname = "Windows_Server_2016_Template_Gold_HW_Ver_5.0"
$num_disks = "1"
#$ds = "testvms"
$format = "thin"
$size = "3"
$vm = Get-VM $vmname

### Add $num_disks to VM

get-vm $vm | shutdown-vmguest -confirm:$false

Start-Sleep -Seconds 150

1..$num_disks | %{
  Write-Host "Adding disk $_ size $size GB and format $format to $($vm.Name)"

  if($_ -eq 1){
      $hd = New-HardDisk -vm $vm -CapacityGB $size -StorageFormat $format
      $hd = Get-HardDisk -VM $vm | Where {$_.ExtensionData.Backing.UUid -eq $hd.ExtensionData.Backing.Uuid}
      $ctrl = New-ScsiController -Type Paravirtual -HardDisk $hd
  }
  else{
      $hd = New-HardDisk -vm $vm -CapacityGB $size -StorageFormat $format -Controller $ctrl
    $hd = Get-HardDisk -VM $vm | Where {$_.ExtensionData.Backing.UUid -eq $hd.ExtensionData.Backing.Uuid}
  }
}

start-vm $vmname

Start-sleep -Seconds 150

get-vm $vm | shutdown-vmguest -confirm:$false

Start-sleep -Seconds 150

Get-HardDisk $vm -name $hd | Remove-HardDisk -DeletePermanently -confirm:$false

Get-ScsiController $vm | Set-ScsiController -Type ParaVirtual -confirm:$false
