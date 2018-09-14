$VCServerName = "usssusvc010"
$VC = Get-VIServer $VCServerName
$VMs = "C:\temp\EpiRocATOSVMs.txt"
$ExportFilePath = "C:\temp\Export-VMInfo.csv"
 
$Report = @()
$Servers = Get-Content $VMs | Get-VM
 
$Datastores = Get-Datastore | Select-Object Name, Id
$VMHosts = Get-VMHost | Select-Object Name, Parent
 
ForEach ($VM in $Servers) {
      $VMView = $VM | Get-View
      $VMInfo = {} | Select VMName,Powerstate,OS,Folder,IPAddress,ToolsStatus,Host,Cluster,Datastore,NumCPU,MemMb,DiskGb, DiskFree, DiskUsed
      $VMInfo.VMName = $vm.name
      $VMInfo.Powerstate = $vm.Powerstate
      $VMInfo.OS = $vm.Guest.OSFullName
      #$VMInfo.Folder = ($vm | Get-Folderpath).Path
      $VMInfo.IPAddress = $vm.Guest.IPAddress[0]
      $VMInfo.ToolsStatus = $VMView.Guest.ToolsStatus
      $VMInfo.Host = $vm.host.name
      $VMInfo.Cluster = $vm.host.Parent.Name
      $VMInfo.Datastore = ($Datastores | where {$_.ID -match (($vmview.Datastore | Select -First 1) | Select Value).Value} | Select Name).Name
      $VMInfo.NumCPU = $vm.NumCPU
      $VMInfo.MemMb = [Math]::Round(($vm.MemoryMB),2)
      $VMInfo.DiskGb = [Math]::Round((($vm.HardDisks | Measure-Object -Property CapacityKB -Sum).Sum * 1KB / 1GB),2)
      $VMInfo.DiskFree = [Math]::Round((($vm.Guest.Disks | Measure-Object -Property FreeSpace -Sum).Sum / 1GB),2)
      $VMInfo.DiskUsed = $VMInfo.DiskGb - $VMInfo.DiskFree
      $Report += $VMInfo
}
$Report = $Report | Sort-Object VMName
IF ($Report -ne "") {
$report | Export-Csv $ExportFilePath -NoTypeInformation
}
$VC = Disconnect-VIServer -Confirm:$False