
Get-HardDisk "VM Name" | Where-Object {$_.Name -eq "hard disk 2"} | Set-HardDisk -CapacityGB 20 -ResizeGuestPartition -Confirm:$false

Get-HardDisk "usssusfs009" | Format-Table filename,name,capacitygb
