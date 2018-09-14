

function Get-ACADinfo {

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

$Alive = $ADArray | Where-Object {$_.Results -eq 'Active'}
$Dead = $ADArray | Where-Object {$_.Results -eq 'InActive'}

function Get-ACSEPinfo {

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

function Get-ACBEXinfo {

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
