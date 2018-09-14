  #####################################    
  ## http://kunaludapi.blogspot.com    
  ## Version: 1    
  ## Tested this script on successfully    
  ## 1) Powershell v4  
  ## 2) Powercli v5.5    
  ## 2) Windows 7   
  ## 3) vSphere 5.5 (vcenter, esxi, powercli)   
  #####################################

get-Viserver @('usssusis019','ssisusvc0005','ssdsbrvc0001');

function Get-VMHostinventory {   

    foreach ($vmhost in Get-VMHost) {  
     Write-host $vmhost.Name  

     if ($vmhost.Version -ne "4.1.0") {  
       $esxcli = $vmhost | Get-EsxCli  
       $serviceTag = $esxcli.hardware.platform.get().SerialNumber  
     }  
        else {  
             $serviceTag = $vmhost.ExtensionData.summary.hardware.otheridentifyinginfo | select-object -ExpandProperty IdentifierValue -last 1  
        }  
             
     #Esxihost Management IP and vlan ID  
     $Managementinfo = $vmhost | Get-VMHostNetworkAdapter | Where-Object {$_.ManagementTrafficEnabled -eq $true}  
     $VirtualPortGroup = $vmhost | Get-VirtualPortGroup  
        $IPinfo = $Managementinfo | select-object -ExpandProperty ip  
     $ManagementPortGroup = $Managementinfo.extensiondata.spec  
     $ManagementIP = $IPinfo -join ", "  
       
     $MulitvLans = @()  
     if ($ManagementPortGroup.DistributedVirtualPort -ne $null) {  
       $vLanIDinfo = $VirtualPortGroup | Where-Object {$Managementinfo.PortGroupName -contains $_.name}  
       foreach ($MGMTVlan in $vLanIDinfo) {  
         $MulitvLans += $MGMTVlan.ExtensionData.config.DefaultPortConfig.Vlan.VlanId  
       }  
       $vLanID = $MulitvLans -join ", "  
     }  
     else {  
       $vLanIDinfo = $VirtualPortGroup | Where-Object {$ManagementPortGroup.Portgroup -contains $_.name } | Select-Object -ExpandProperty VLanId  
       foreach ($MGMTVlan in $vLanIDinfo) {  
         $MulitvLans += $MGMTVlan  
       }  
     $vLanID = $MulitvLans -join ", "  
     }  
       
     #EsxiHost CPU info  
     $HostCPU = $vmhost.ExtensionData.Summary.Hardware.NumCpuPkgs  
     $HostCPUcore = $vmhost.ExtensionData.Summary.Hardware.NumCpuCores/$HostCPU  
   
     #All Virtual Machines Info  
     $VMs = $vmhost | Get-VM   
     $PoweredOnVM = $VMs | Where-Object {$_.PowerState -eq "PoweredOn"}  
   
     #EsxiHost and VM -- CPU calculation  
     $AssignedTotalvCPU = $VMs | Measure-Object NumCpu -Sum | Select-Object -ExpandProperty sum  
     $PoweredOnvCPU = $PoweredOnVM | Measure-Object NumCpu -Sum | Select-Object -ExpandProperty sum  
     $onecoreMhz = $vmhost.CPUTotalMhz / $vmhost.NumCpu  
     $TotalPoweredOnMhz = $onecoreMhz * $PoweredOnvCPU  
       
     #EsxiHost and VM -- Memory calculation  
     $TotalMemory = [math]::round($vmhost.MemoryTotalGB)  
     $Calulatedvmmemory = $VMs | Measure-Object MemoryGB -sum | Select-Object -ExpandProperty sum  
     $TotalvmMemory = [math]::round($Calulatedvmmemory)  
     $Calulatedvmmemory = $PoweredOnVM | Measure-Object MemoryGB -sum | Select-Object -ExpandProperty sum  
     $PoweredOn_vMemory = "{0:N2}" -f $Calulatedvmmemory  
   
     #EsxiHost Domain Details  
     $domain = ($vmhost | Get-VMHostAuthentication).Domain  
   
     #Cluster and Datstore info  
     $Clusterinfo = $vmhost | Get-Cluster  
     $Clustername = $Clusterinfo.Name  
     $DataCenterinfo = Get-DataCenter -VMHost $VMHost.Name  
     $Datacentername = $DataCenterinfo.Name  
   
     #vCenterinfo  
     $vCenter = $vmhost.ExtensionData.CLient.ServiceUrl.Split('/:')[3]  
     $vcenterversion = $global:DefaultVIServers | where {$_.Name -eq $vCenter} | %{"$($_.Version) build $($_.Build)"}  
   
     #vmhost SSH service Staus  
     $SSHservice = $vmhost | Get-VMHostService | Where-object {$_.key -eq "Tsm-ssh"} | Select-Object -ExpandProperty running  
   
     #vmhost Uptime  
     $UPtime = (Get-Date) - ($vmhost.ExtensionData.Runtime.BootTime) | Select-Object -ExpandProperty days  
   
     #vmhost syslog server settings  
     if ($vmhost.Version -ne "4.1.0") {  
       $syslog = ($vmhost | Get-AdvancedSetting -Name Syslog.global.logHost).value  
     }  
     else {$syslog = "Not Supported"}  
           
       
     #vmhost Dump collector  
     $DumpCollector = $esxcli.system.coredump.network.get().NetworkServerIP  
   
     $VmHostresult = New-Object PSObject   
     $VmHostresult | add-member -MemberType NoteProperty -Name "Name" -Value $vmhost.Name  
     $VmHostresult | add-member -MemberType NoteProperty -Name "Management IP" -Value $ManagementIP  
     $VmHostresult | add-member -MemberType NoteProperty -Name "vLan ID" -Value $vlanID  
     $VmHostresult | add-member -MemberType NoteProperty -Name "PowerState" -Value $vmhost.PowerState  
     $VmHostresult | add-member -MemberType NoteProperty -Name "Manufacturer" -Value $vmhost.Manufacturer  
     $VmHostresult | add-member -MemberType NoteProperty -Name "Model" -Value $vmhost.Model  
     $VmHostresult | add-member -MemberType NoteProperty -Name "Service_Tag" -Value $serviceTag  
     $VMHostresult | add-member -MemberType NoteProperty -Name "TotalVms" -Value $VMs.count  
     $VMHostresult | add-member -MemberType NoteProperty -Name "PoweronVMs" -Value $PoweredOnvm.Count  
     $VmHostresult | add-member -MemberType NoteProperty -Name "ProcessorType" -Value $VMHost.ProcessorType  
     $VmHostresult | add-member -MemberType NoteProperty -Name "CPU_Sockets" -Value $HostCPU  
     $VmHostresult | add-member -MemberType NoteProperty -Name "CPU_core_per_socket" -Value $HostCPUcore  
     $VmHostresult | add-member -MemberType NoteProperty -Name "Logical_CPUs" -Value $vmhost.Numcpu  
     $VmHostresult | add-member -MemberType NoteProperty -Name "TotalHost_Mhz" -Value $vmhost.CPUTotalMhz  
     $VmHostresult | add-member -MemberType NoteProperty -Name "AssignedTotal_vCPUs" -Value $AssignedTotalvCPU  
     $VmHostresult | add-member -MemberType NoteProperty -Name "PoweredOn_vCPUs" -Value $PoweredOnvCPU  
     $VmHostresult | add-member -MemberType NoteProperty -Name "PoweredOn_Mhz" -Value $TotalPoweredOnMhz  
     $VmHostresult | add-member -MemberType NoteProperty -Name "Memory(GB)" -Value $TotalMemory  
     $VmHostresult | add-member -MemberType NoteProperty -Name "AssignedTotal-vMemory(GB)" -Value $TotalvmMemory  
     $VmHostresult | add-member -MemberType NoteProperty -Name "PoweredOn-vMemory(GB)" -Value $PoweredOn_vMemory  
     $VmHostresult | add-member -MemberType NoteProperty -Name "Esxi-Version" -Value $vmhost.Version  
     $VmHostresult | add-member -MemberType NoteProperty -Name "Build-Number" -Value $vmhost.Build  
     $VmHostresult | add-member -MemberType NoteProperty -Name "Domain" -Value $domain  
     $VmHostresult | add-member -MemberType NoteProperty -Name "Max-EVC-Key" -Value $vmhost.ExtensionData.Summary.MaxEVCModeKey  
     $VmHostresult | add-member -MemberType NoteProperty -Name "Cluster" -Value $ClusterName  
     $VmHostresult | add-member -MemberType NoteProperty -Name "DataCenter" -Value $DatacenterName  
     $VmHostresult | add-member -MemberType NoteProperty -Name "vCenter Server" -Value $vcenter  
     $VmHostresult | add-member -MemberType NoteProperty -Name "vCenter version" -Value $vcenterversion  
     $VMHostresult | add-member -MemberType NoteProperty -Name "Esxi-status" -Value $vmhost.ExtensionData.Summary.OverallStatus  
     $VMHostresult | add-member -MemberType NoteProperty -Name "Physical-Nics" -Value $vmhost.ExtensionData.summary.hardware.NumNics  
     $VMHostresult | add-member -MemberType NoteProperty -Name "SSH-Enabled" -Value $SSHservice  
     $VMHostresult | add-member -MemberType NoteProperty -Name "Uptime" -Value $UPtime  
     $VMHostresult | add-member -MemberType NoteProperty -Name "Syslog-Server" -Value $syslog  
     $VMHostresult | add-member -MemberType NoteProperty -Name "Dump-Collector" -Value $DumpCollector  
     $VmHostresult   
   }  
 }  
 Get-VMHostinventory   

#To write information to csv file
Get-VMHostinventory | export-csv -notypeinformation -path c:\temp\vmhostlist.csv