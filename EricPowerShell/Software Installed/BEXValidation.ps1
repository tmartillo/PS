$File = Import-Csv 'c:\temp\ADServerList.csv' #NOTE: the first line of this file must say machinename
$csvFilePath = "C:\Temp\BEXValidationTest.csv"
# Check if .CSV file exist, and create empty one with column names of the software I am searching for
if (!(Test-Path -path $csvFilePath)) { ""| Select Name, BackupSoftware, AgentVersion | 
Export-Csv -Path $csvFilePath -NoTypeInformation}
 
$BEXArray = New-Object -TypeName System.Collections.ArrayList

foreach ($line in $file){$machinename = $line.machinename
            (Get-WmiObject -computername $MachineName Win32_Service -Filter "Name='RemoteRegistry'") | Out-Null
            $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$machinename)
			$RegKeyBEX = $Reg.OpenSubKey("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Remote Agent for Windows Servers")
            $VersionBEXName = $RegKeyBEX.GetValue("DisplayName")
            $VersionBEXVer = $RegKeyBEX.GetValue("DisplayVersion")
            $row = ""| Select Name, BackupSoftware, AgentVersion
            $row.Name = $MachineName.ToString()
            $row.BackupSoftware = $VersionBEXName
            $row.AgentVersion = $VersionBEXVer
            $BEXArray.Add($row)
            Remove-Variable Reg,VersionBEXName,VersionBEXVer
            }
 
$BEXArray | Export-Csv -Path $csvFilePath -NoTypeInformation -Append
Write-Host "Script finished execution" -ForegroundColor Green