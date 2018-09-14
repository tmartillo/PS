# New vHD's for VM, initialize and format.
# Key assumption that there's 1 hard drive on the VM
# Add or remove 

$VM = 'VMNAMEHERE'

ForEach ($HardDisk in (1))
    { 
        New-HardDisk -VM $VM -CapacityGB '100' -StorageFormat 'Thin' -Verbose
    } 
ForEach ($HardDisk in (1))
    { 
        New-HardDisk -VM $VM -CapacityGB '20' -StorageFormat 'Thin' -Verbose
    } 
ForEach ($HardDisk in (1))
    { 
        New-HardDisk -VM $VM -CapacityGB '40' -StorageFormat 'Thin' -Verbose
    }
ForEach ($HardDisk in (1))
    { 
        New-HardDisk -VM $VM -CapacityGB '160' -StorageFormat 'Thin' -Verbose
    }

Enter-PSSession $VM

# If you get an error it's probably because the CD-ROM is using the drive letter "D:\"

Get-Disk | Where-Object partitionstyle -eq 'raw' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize
Format-Volume -FileSystem NTFS -Confirm:$false -DriveLetter 'd'