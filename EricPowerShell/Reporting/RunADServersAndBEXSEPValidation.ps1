#######################################################################################
## Gather all AD Server OS objects and find A/V client, Backup client
##
########################################################################################

###########################################################################################################################
###########################################################################################################################
## Code to take the compiled list and "test" connection
##
## Most code from http://stackoverflow.com/questions/25757258/test-connection-output-to-csv-file-with-hostname-and-ipaddress
##
## Pulls all server obects from AD and adds the collection to a csvfile
## Modify this line to save CSV file "Export-Csv C:\install\ServerStatus2.csv -NoTypeInformation"
###########################################################################################################################
###########################################################################################################################

$ServersList=Get-ADComputer -Filter {OperatingSystem -Like "Windows *Server*"} -Property * -searchbase 'ou=servers,ou=garland,ou=uss,ou=mr,DC=nasa,DC=group,DC=atlascopco,DC=com' | sort-object name | `
foreach {
    $obj = "" | select Name,DistinguishedName,LastLogonDate,OperatingSystem
    [string]$obj.Name = $_.Name
    [string]$obj.OperatingSystem = $_.OperatingSystem
#    [string]$obj.distinguishedname = $_.distinguishedname.split([string[]]"$Header,", [StringSplitOptions]"None")[2]
    [string]$obj.DistinguishedName = $_.DistinguishedName
    [string]$obj.LastLogonDate = $_.LastLogonDate
        $obj
}

$ADArray = $()

foreach ($server in $ServersList) {
              
            $status = @{ "ServerName" = $server.name ; "OU" = $server.DistinguishedName ; `
            "Last Logon Date" = $server.LastLogonDate ; "ReportTime" = (Get-Date -f s) ; "Results"="" ; `
            "OperatingSystem" = $server.OperatingSystem}

if (Test-Connection -computername $server.name -Count 3 -ea 0 -quiet)

{ 
    $status["Results"] = "Active"
} 
else 
{ 
    $status["Results"] = "Inactive" 
}
New-Object -TypeName PSObject -Property $status -OutVariable ServerStatus
$ADArray += $ServerStatus

}

Write-Host "Script finished gathering AD Server's" -ForegroundColor Green

#Where-Object {$_status -eq 'Active'}

$Alive = $ADArray | Where-Object {$_.Results -eq 'Active'}
$Dead = $ADArray | Where-Object {$_.Results -eq 'InActive'}


###########################################################################################
## Filename: Query-SoftwareOnRemotePc_ADSI.ps1 
## Date:     July, 2014
## Author:   Alex Dujakovic 
## Description: PowerShell script to get the list of software installed on remote computers
## In a loop, an array receives a lot of new items using the operator "+="
## to speed up this array operation, in this example I will use ArrayList
###########################################################################################

$SoftwareArray = New-Object -TypeName System.Collections.ArrayList

foreach ($line in $Alive.ServerName){$machinename = $line
            (Get-WmiObject -computername $MachineName Win32_Service -Filter "Name='RemoteRegistry'") | Out-Null
            $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$machinename)
			$RegKeySEP= $Reg.OpenSubKey("SOFTWARE\\Symantec\\Symantec Endpoint Protection\\CurrentVersion")
            $VersionSEP = $RegKeySEP.GetValue("PRODUCTVERSION")
			$RegKeySEPVer= $Reg.OpenSubKey("SOFTWARE\\Symantec\\Symantec Endpoint Protection\\SMC")
			$VersionSEPInst = $RegKeySEPVer.GetValue("ProductVersion")
            $RegKeyBEX = $Reg.OpenSubKey("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Remote Agent for Windows Servers")
            $VersionBEXName = $RegKeyBEX.GetValue("DisplayName")
            $VersionBEXVer = $RegKeyBEX.GetValue("DisplayVersion")
            $RegKeyBEX = $Reg.OpenSubKey("SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate")
            $WindowsUpdate = $RegKeyBEX.GetValue("WUServer")
            $row = ""| Select ServerName, SEP, SEPVersion, SEPInstalled, BackupSoftware, BUAgentVer, WSUS
            $row.ServerName = $MachineName.ToString()
            $row.SEPVersion = $VersionSEP
			$row.SEPInstalled = $VersionSEPInst
            $row.BackupSoftware = $VersionBEXName
            $row.BUAgentVer = $VersionBEXVer
            $row.WSUS = $WindowsUpdate
            $SoftwareArray.Add($row)
            Remove-Variable Reg,VersionSEP,VersionSEPInst,VersionBEXName,VersionBEXVer,WindowsUpdate
            }

Write-Host "Script finished gathering software information" -ForegroundColor Green

#########################################################################################
## Get VMGuest Info
##
##
#########################################################################################

    get-Viserver @('usssusvs001');
    
$VMArray = foreach ($vm in Get-VM) {  
     Write-Host $vm.Name  
     #All global info here  
     $GlobalHDDinfo = $vm | Get-HardDisk  
     $vNicInfo = $vm | Get-NetworkAdapter  
     $Snapshotinfo = $vm | Get-Snapshot  
     $Resourceinfo = $vm | Get-VMResourceConfiguration  
       
     #IPinfo  
     $IPs = $vm.Guest.IPAddress -join "," #$vm.Guest.IPAddres[0] <#it will take first ip#>  
   
     #FQDN - AD domain name
     $OriginalHostName = $vm.ExtensionData.Guest.Hostname.trimend("nasa.group.atlascopco.com")
     #$OriginalHostName = $($vm.ExtensionData.Guest.Hostname -split '\.')[0]  
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
     $Datacenter = $vm | Get-Datacenter | Select-Object -ExpandProperty name  
   
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
       
     $VMResult = New-Object PSObject   
     $Vmresult | add-member -MemberType NoteProperty -Name "VMName" -Value $vm.Name  
     $Vmresult | add-member -MemberType NoteProperty -Name "IP Address" -Value $IPs  
     $Vmresult | add-member -MemberType NoteProperty -Name "PowerState" -Value $vm.PowerState  
     $Vmresult | add-member -MemberType NoteProperty -Name "ServerName" -Value $OriginalHostName  
     $Vmresult | add-member -MemberType NoteProperty -Name "DomainName" -Value $Domainname  
     $Vmresult | add-member -MemberType NoteProperty -Name "vCPU" -Value $vm.NumCpu  
     $Vmresult | Add-Member -MemberType NoteProperty -Name CPUSocket -Value $vm.ExtensionData.config.hardware.NumCPU  
     $Vmresult | Add-Member -MemberType NoteProperty -Name Corepersocket -Value $vm.ExtensionData.config.hardware.NumCoresPerSocket  
     $Vmresult | add-member -MemberType NoteProperty -Name "RAM(GB)" -Value $vm.MemoryGB  
     $Vmresult | add-member -MemberType NoteProperty -Name "Total-HDD(GB)" -Value $TotalHDDs  
     $Vmresult | add-member -MemberType NoteProperty -Name "HDDs(GB)" -Value $HDDsGB  
     $Vmresult | add-member -MemberType NoteProperty -Name "HDDsType" -Value $HDDtypeResult  
     $Vmresult | add-member -MemberType NoteProperty -Name "Datastore" -Value $datastore  
     $Vmresult | add-member -MemberType NoteProperty -Name "FreeSpace/Size" -Value $internalHDDResult  
     $Vmresult | add-member -MemberType NoteProperty -Name "Installed-OS" -Value $vm.guest.OSFullName  
     $Vmresult | add-member -MemberType NoteProperty -Name "Setting-OS" -Value $VM.ExtensionData.summary.config.guestfullname  
     $Vmresult | add-member -MemberType NoteProperty -Name "EsxiHost" -Value $VM.VMHost  
     $Vmresult | add-member -MemberType NoteProperty -Name "vCenter" -Value $vCenter  
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
     $Vmresult | add-member -MemberType NoteProperty -Name "DataCenter" -Value $datacenter  
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
     $VMResult
}



$SEPList = $SoftwareArray | % { $_.servername }

$BEXList = $SoftwareArray | % { $_.servername }

$WSUSList = $SoftwareArray | % { $_.servername }

$VMList = $VMArray | % { $_.ServerName }

$List = foreach ($server in $ADArray) {
    $obj = "" | select ServerName,SEPVersion,SEPInstalled,OU,Operatingsystem,BackupSoftware,BUAgentVer,WSUS,DomainName
                
    $obj.servername = $server.servername
    $obj.OU = $server.OU
    $obj.operatingsystem = $server.Operatingsystem

    if ($SEPList -contains $server.servername) {
        
        $obj.SEPVersion = ($SoftwareArray | ? { $_.servername -eq $server.servername }).SEPversion
        $obj.SEPInstalled = ($SoftwareArray | ? { $_.servername -eq $server.servername }).SEPinstalled
        
    }

    if ($BEXList -contains $server.servername) {
                
       $obj.BackupSoftware = ($SoftwareArray | ? { $_.servername -eq $server.servername }).BackupSoftware
       $obj.BUAgentVer = ($SoftwareArray | ? { $_.servername -eq $server.servername }).BUAgentVer

    }

    if ($WSUSList -contains $server.servername) {
                
       $obj.WSUS = ($SoftwareArray | ? { $_.servername -eq $server.servername }).WSUS
           
    }

    if ($VMList -contains $server.ServerName) {
                
       $obj.VMList = ($VMArray | ? { $_.servername -eq $server.servername }).DomainName

}

    $obj
}




function Get-ADinfo {

    param (
        #$OU = 'DC=nasa,DC=group,DC=atlascopco,DC=com'
        $OU,
        $Filter
    )

    $ServersList=Get-ADComputer -Filter {OperatingSystem -Like $Filter} -Property * -searchbase $OU | sort-object name | `
    foreach { 
        $obj = "" | select Name,DistinguishedName,LastLogonDate,OperatingSystem
        [string]$obj.Name = $_.Name
        [string]$obj.OperatingSystem = $_.OperatingSystem
    #    [string]$obj.distinguishedname = $_.distinguishedname.split([string[]]"$Header,", [StringSplitOptions]"None")[2]
        [string]$obj.DistinguishedName = $_.DistinguishedName
        [string]$obj.LastLogonDate = $_.LastLogonDate
            $obj
    }

    $ADArray = $()

    foreach ($server in $ServersList) {
                
                $status = @{ "ServerName" = $server.name ; "OU" = $server.DistinguishedName ; `
                "Last Logon Date" = $server.LastLogonDate ; "ReportTime" = (Get-Date -f s) ; "Results"="" ; `
                "OperatingSystem" = $server.OperatingSystem}

    if (Test-Connection -computername $server.name -Count 3 -ea 0 -quiet)

    { 
        $status["Results"] = "Active"
    } 
    else 
    { 
        $status["Results"] = "Inactive" 
    }
    New-Object -TypeName PSObject -Property $status -OutVariable ServerStatus
    $ADArray += $ServerStatus

    }

    Write-Host "Script finished gathering AD Server's" -ForegroundColor Green

    $ADarray

}

function Get-SEPinfo {

    $SEPArray = New-Object -TypeName System.Collections.ArrayList

            foreach ($line in $Alive.ServerName){$machinename = $line
            (Get-WmiObject -computername $MachineName Win32_Service -Filter "Name='RemoteRegistry'") | Out-Null
            $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$machinename)
			$RegKeySEP= $Reg.OpenSubKey("SOFTWARE\\Symantec\\Symantec Endpoint Protection\\CurrentVersion")
            $VersionSEP = $RegKeySEP.GetValue("PRODUCTVERSION")
			$RegKeySEPVer= $Reg.OpenSubKey("SOFTWARE\\Symantec\\Symantec Endpoint Protection\\SMC")
			$VersionSEPInst = $RegKeySEPVer.GetValue("ProductVersion")
            $row = ""| Select ServerName, SEP, SEPVersion, SEPInstalled
            $row.ServerName = $MachineName.ToString()
            $row.SEP = "Symantec Endpoint Protection"
            $row.SEPVersion = $VersionSEP
			$row.SEPInstalled = $VersionSEPInst
            $SEPArray.Add($row)
            Remove-Variable Reg,VersionSEP,VersionSEPInst
            }
    Write-Host "Script finished SEP validation execution" -ForegroundColor Green

    $SEPArray
}

function Get-BEXinfo {

    $BEXArray = New-Object -TypeName System.Collections.ArrayList

            foreach ($line in $Alive.ServerName){$machinename = $line
            (Get-WmiObject -computername $MachineName Win32_Service -Filter "Name='RemoteRegistry'") | Out-Null
            $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$machinename)
			$RegKeyBEX = $Reg.OpenSubKey("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Remote Agent for Windows Servers")
            $VersionBEXName = $RegKeyBEX.GetValue("DisplayName")
            $VersionBEXVer = $RegKeyBEX.GetValue("DisplayVersion")
            $row = ""| Select ServerName, BackupSoftware, BUAgentVer
            $row.ServerName = $MachineName.ToString()
            $row.BackupSoftware = $VersionBEXName
            $row.BUAgentVer = $VersionBEXVer
            $BEXArray.Add($row)
            Remove-Variable Reg,VersionBEXName,VersionBEXVer
            }
 Write-Host "Script finished BEX validation execution" -ForegroundColor Green

    $BEXArray
}


