# ******************************************************************************

$File = Import-Csv 'c:\temp\hostlist.csv' #NOTE: the first line of this file must say machinename

foreach ($line in $file)

{

$machinename = $line.machinename

#Continue the script even if an error happens

trap [Exception] {continue}

$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine",$MachineName)

#Set the Reg Container

$key = "SOFTWARE\\Symantec\\Symantec Endpoint Protection\\SMC"

$regkey = "" #clears the value between loop runs

$regkey = $reg.opensubkey($key)

$SEPver = "" #clears the value between loop runs

#NOTE: the values between the " ' " symbols are the key you're looking for

$SEPver = $regKey.GetValue('ProductVersion')

$Results = $MachineName , $SEPver

Write-host $Results

#Write-Output ************

}