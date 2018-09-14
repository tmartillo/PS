   
###########################################################################################
# Filename: Query-SoftwareOnRemotePc_ADSI.ps1 
# Date:     July, 2014
# Author:   Alex Dujakovic 
# Description: PowerShell script to get the list of software installed on remote computers
# In a loop, an array receives a lot of new items using the operator "+="
# to speed up this array operation, in this example I will use ArrayList
###########################################################################################

$File = Import-Csv 'c:\temp\SEPServerList.csv' #NOTE: the first line of this file must say machinename
$csvFilePath = "C:\Temp\SepValidation.csv"
# Check if .CSV file exist, and create empty one with column names of the software I am searching for
if (!(Test-Path -path $csvFilePath)) { ""| Select Name, SEP, SEPVersion, SEPInstalled | 
Export-Csv -Path $csvFilePath -NoTypeInformation}

$SEPArray = New-Object -TypeName System.Collections.ArrayList

foreach ($line in $file){$machinename = $line.machinename

        $Status = (Get-WmiObject -computername $MachineName Win32_Service -Filter "Name='RemoteRegistry'")
            if ($Status -ne $null)        
            {
            foreach ($Server in $Status){
            $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$machinename)
			$RegKeySEP= $Reg.OpenSubKey("SOFTWARE\\Symantec\\Symantec Endpoint Protection\\CurrentVersion")
            $VersionSEP = $RegKeySEP.GetValue("PRODUCTVERSION")
			$RegKeySEPVer= $Reg.OpenSubKey("SOFTWARE\\Symantec\\Symantec Endpoint Protection\\SMC")
			$VersionSEPInst = $RegKeySEPVer.GetValue("ProductVersion")
            $row = ""| Select Name, SEP, SEPVersion, SEPInstalled
            $row.Name = $MachineName.ToString()
            $row.SEP = "Symantec Endpoint Protection"
            $row.SEPVersion = $VersionSEP
			$row.SEPInstalled = $VersionSEPInst #This line is to capture SEP ver prior to v12
            $SEPArray.Add($row)
            Remove-Variable Reg,VersionSEP,VersionSEPInst 
            }
        }
            else {
                write-host "Not a Windows server/Unavailable/No Permissions" -ForegroundColor Magenta
            }
}

$SEPArray | Export-Csv -Path $csvFilePath -NoTypeInformation -Append

Write-Host "Script finished execution" -ForegroundColor Green