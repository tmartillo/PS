#####################################   
  ## http://kunaludapi.blogspot.com   
  ## Version: 2  
  ## Date: 27 August 2014    
  ## Script tested on below platform   
  ## 1) Powershell v3   
  ## 2) Powercli v5.1   
  ## 3) Vsphere 5.1   
  ####################################  

get-Viserver @('usssusis019','ssisusvc0005','ssdsbrvc0001');

function Get-VMGuestInventory { 

   foreach ($vm in Get-VM) {  
     Write-Host $vm.Name  
     #All global info here  
     $GlobalHDDinfo = $vm | Get-HardDisk  
     $vNicInfo = $vm | Get-NetworkAdapter  
     $Snapshotinfo = $vm | Get-Snapshot  
     $Resourceinfo = $vm | Get-VMResourceConfiguration  
       
     #IPinfo  
     $IPs = $vm.Guest.IPAddress -join "," #$vm.Guest.IPAddres[0] <#it will take first ip#>  
   
     #FQDN - AD domain name  
     $OriginalHostName = $($vm.ExtensionData.Guest.Hostname -split '\.')[0]  
     #$Domainname = $($vm.ExtensionData.Guest.Hostname -split '\.')[0] -join '.'  
     $Domainname = $($vm.ExtensionData.Guest.Hostname) -join '.'

     #All hardisk individual capacity  
     $TotalHDDs = $vm.ProvisionedSpaceGB -as [int]  
     
     #All hardisk individual capacity  
       
     $HDDsGB = $($GlobalHDDinfo | select-object -ExpandProperty CapacityGB) -join " + "  
   
     #All HDD disk type,($vdisk.Capacity /1GB -as [int])}  
     $HDDtype = foreach ($HDDtype in $GlobalHDDinfo) {"{0}={1}GB"-f ($HDDtype.Name), ($HDDtype.StorageFormat)}  
     $HDDtypeResult = $HDDtype -join (", ")  
   
     #Associated Datastores  
     $datastore = $(Get-Datastore -vm $vm) -split ", " -join ", "  
     
     #Guest OS Internal HDD info  
     $internalHDDinfo = ($vm | get-VMGuest).ExtensionData.disk  
     $internalHDD = foreach ($vdisk in $internalHDDinfo) {"{0}={1}GB/{2}GB"-f ($vdisk.DiskPath), ($vdisk.FreeSpace /1GB -as [int]),($vdisk.Capacity /1GB -as [int])}  
     $internalHDDResult = $internalHDD -join (", ")  
   
     #vCenter Server  
     $vCenter = $vm.ExtensionData.Client.ServiceUrl.Split('/')[2].trimend(":443")   
   
     #VM Macaddress  
     $Macaddress = $vNicInfo.MacAddress -join ", "  
   
     #Vmdks and its location  
     $vmdk = $GlobalHDDinfo.filename -join ", "  
   
     #Snapshot info  
     $snapshot = $Snapshotinfo.count  
     
     #Datacenter info  
     $datacenter = $vm | Get-Datacenter | Select-Object -ExpandProperty name  
   
     #Cluster info  
     $cluster = $vm | Get-Cluster | Select-Object -ExpandProperty name  
   
     #vNic Info  
     $vNics = foreach ($vNic in $VnicInfo) {"{0}={1}"-f ($vnic.Name.split("")[2]), ($vNic.Type)}  
     $vnic = $vNics -join (", ")  
   
     #Virtual Port group Info  
     $portgroup = $vNicInfo.NetworkName -join ", "  
   
     #RDM Disk Info  
     $RDMInfo = $GlobalHDDinfo | Where-Object {$_.DiskType -eq "RawPhysical"-or $_.DiskType -eq "RawVirtual"}   
     $RDMHDDs = foreach ($RDM in $RDMInfo) {"{0}/{1}/{2}/{3}"-f ($RDM.Name), ($RDM.DiskType),($RDM.Filename), ($RDM.ScsiCanonicalName)}  
     $RDMs = $RDMHDDs -join (", ")  
   
#     #Custom Attributes  
#     $Annotation = $vm | Get-Annotation  
#     $Project = $Annotation | Where-Object {$_.Name -eq "Project"} | Select-Object -ExpandProperty value  
#     $SubProject = $Annotation | Where-Object {$_.Name -eq "SubProject"} | Select-Object -ExpandProperty value  
#     $Environment = $Annotation | Where-Object {$_.Name -eq "Environment"} | Select-Object -ExpandProperty value  
#     $Application = $Annotation | Where-Object {$_.Name -eq "Application"} | Select-Object -ExpandProperty value  
#     $Owner = $Annotation | Where-Object {$_.Name -eq "Owner"} | Select-Object -ExpandProperty value  
#     $Creationdate = $Annotation | Where-Object {$_.Name -eq "CreationDate"} | Select-Object -ExpandProperty value  
#     $Email = $Annotation | Where-Object {$_.Name -eq "Email"} | Select-Object -ExpandProperty value  
       
     $Vmresult = New-Object PSObject   
     $Vmresult | add-member -MemberType NoteProperty -Name "VMName" -Value $vm.Name  
     $Vmresult | add-member -MemberType NoteProperty -Name "IP Address" -Value $IPs  
     $Vmresult | add-member -MemberType NoteProperty -Name "PowerState" -Value $vm.PowerState  
     $Vmresult | add-member -MemberType NoteProperty -Name "ServerName" -Value $OriginalHostName  
     $Vmresult | add-member -MemberType NoteProperty -Name "Domain Name" -Value $Domainname  
     $Vmresult | add-member -MemberType NoteProperty -Name "vCPU" -Value $vm.NumCpu  
     $Vmresult | Add-Member -MemberType NoteProperty -Name "CPUSocket" -Value $vm.ExtensionData.config.hardware.NumCPU  
     $Vmresult | Add-Member -MemberType NoteProperty -Name "Corepersocket" -Value $vm.ExtensionData.config.hardware.NumCoresPerSocket  
     $Vmresult | add-member -MemberType NoteProperty -Name "RAM(GB)" -Value $vm.MemoryGB  
     $Vmresult | add-member -MemberType NoteProperty -Name "Total-HDD(GB)" -Value $TotalHDDs  
     $Vmresult | add-member -MemberType NoteProperty -Name "HDDs(GB)" -Value $HDDsGB  
     $Vmresult | add-member -MemberType NoteProperty -Name "HDDsType" -Value $HDDtypeResult  
     $Vmresult | add-member -MemberType NoteProperty -Name "Datastore" -Value $datastore  
     $Vmresult | add-member -MemberType NoteProperty -Name "FreeSpace/Size" -Value $internalHDDResult  
     $Vmresult | add-member -MemberType NoteProperty -Name "Installed-OS" -Value $vm.guest.OSFullName  
     $Vmresult | add-member -MemberType NoteProperty -Name "Setting-OS" -Value $VM.ExtensionData.summary.config.guestfullname  
     $Vmresult | add-member -MemberType NoteProperty -Name "EsxiHost" -Value $VM.VMHost  
     $Vmresult | add-member -MemberType NoteProperty -Name "vCenter Server" -Value $vCenter  
     $Vmresult | add-member -MemberType NoteProperty -Name "Hardware Version" -Value $vm.Version  
     $Vmresult | add-member -MemberType NoteProperty -Name "Folder" -Value $vm.folder  
     $Vmresult | add-member -MemberType NoteProperty -Name "MacAddress" -Value $macaddress  
     $Vmresult | add-member -MemberType NoteProperty -Name "VMX" -Value $vm.ExtensionData.config.files.VMpathname  
     $Vmresult | add-member -MemberType NoteProperty -Name "VMDK" -Value $vmdk  
     $Vmresult | add-member -MemberType NoteProperty -Name "VMTools Status" -Value $vm.ExtensionData.Guest.ToolsStatus  
     $Vmresult | add-member -MemberType NoteProperty -Name "VMTools Version" -Value $vm.ExtensionData.Guest.ToolsVersion  
     $Vmresult | add-member -MemberType NoteProperty -Name "VMTools Version Status" -Value $vm.ExtensionData.Guest.ToolsVersionStatus  
     $Vmresult | add-member -MemberType NoteProperty -Name "VMTools Running Status" -Value $vm.ExtensionData.Guest.ToolsRunningStatus  
     $Vmresult | add-member -MemberType NoteProperty -Name "SnapShots" -Value $snapshot  
     $Vmresult | add-member -MemberType NoteProperty -Name "datacenter" -Value $datacenter  
     $Vmresult | add-member -MemberType NoteProperty -Name "Cluster" -Value $cluster  
     $Vmresult | add-member -MemberType NoteProperty -Name "vNic" -Value $vNic  
     $Vmresult | add-member -MemberType NoteProperty -Name "Portgroup" -Value $portgroup  
     $Vmresult | add-member -MemberType NoteProperty -Name "RDM" -Value $RDMs  
     $Vmresult | add-member -MemberType NoteProperty -Name "Project" -Value $Project  
     $Vmresult | add-member -MemberType NoteProperty -Name "SubProject" -Value $SubProject  
     $Vmresult | add-member -MemberType NoteProperty -Name "Environment" -Value $Environment  
     $Vmresult | add-member -MemberType NoteProperty -Name "Application" -Value $Application  
     $Vmresult | add-member -MemberType NoteProperty -Name "Email" -Value $Email  
     $Vmresult | add-member -MemberType NoteProperty -Name "Owner" -Value $Owner  
     $Vmresult | add-member -MemberType NoteProperty -Name "CreationDate" -Value $Creationdate  
     $Vmresult | add-member -MemberType NoteProperty -Name "NumCpuShares" -Value $Resourceinfo.NumCpuShares  
     $Vmresult | add-member -MemberType NoteProperty -Name "CpuReservationMhz" -Value $Resourceinfo.CpuReservationMhz  
     $Vmresult | add-member -MemberType NoteProperty -Name "CpuLimitMhz" -Value $Resourceinfo.CpuLimitMhz  
     $Vmresult | add-member -MemberType NoteProperty -Name "CpuSharesLevel" -Value $Resourceinfo.CpuSharesLevel  
     $Vmresult | add-member -MemberType NoteProperty -Name "NumMemShares" -Value $Resourceinfo.NumMemShares  
     $Vmresult | add-member -MemberType NoteProperty -Name "MemReservationGB" -Value $Resourceinfo.MemReservationGB  
     $Vmresult | add-member -MemberType NoteProperty -Name "MemLimitGB" -Value $Resourceinfo.MemLimitGB  
     $Vmresult | add-member -MemberType NoteProperty -Name "MemSharesLevel" -Value $Resourceinfo.MemSharesLevel  
     $Vmresult | add-member -MemberType NoteProperty -Name "NumDiskShares" -Value $Resourceinfo.DiskResourceConfiguration.NumDiskShares  
     $Vmresult | add-member -MemberType NoteProperty -Name "DiskSharesLevel" -Value $Resourceinfo.DiskResourceConfiguration.DiskSharesLevel  
     $Vmresult | add-member -MemberType NoteProperty -Name "CpuAffinityList" -Value $Resourceinfo.CpuAffinityList  
     $Vmresult  
   }
}
Get-VMGuestInventory 

Get-VMGuestInventory | export-csv -notypeinformation -path c:\temp\VMGuestList.csv