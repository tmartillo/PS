# New vHard drive for VM, initialize and format.
# Key assumption that there's on 1 hard drive on the VM

$disksizeGB = '100'
$VM = 'usssusas0005'

New-HardDisk -SizeGB $disksizeGB -StorageFormat 'thin' -VM $VM

Enter-PSSession $VM

Get-Disk | Where-Object partitionstyle -eq 'raw' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize
Format-Volume -FileSystem NTFS -Confirm:$false -DriveLetter 'd'