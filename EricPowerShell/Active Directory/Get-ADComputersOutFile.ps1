#Code from numerous sources

#This is the path where you would like to save your csv file
$csvFilePath = "C:\FilePathHere"

Get-ADComputer -Filter {OperatingSystem -Like "Windows *Server*"} -Property * | Sort-Object name
| format-Table Name -Wrap -Auto |  Out-File $csvFilePath






############
# Code to take the compiled list and "test" connection
#
#Most code from http://stackoverflow.com/questions/25757258/test-connection-output-to-csv-file-with-hostname-and-ipaddress
#

$ServersList=Get-ADComputer -Filter {OperatingSystem -Like "Windows *Server*"} -Property * | sort-object name |  foreach { [string]$_.name}
$Collection = $()
foreach ($name in $ServersList){
              
            $status = @{ "ServerName" = $name; "TimeStamp" = (Get-Date -f s); "Results"=""}

if (Test-Connection -computername $name -Count 2 -ea 0 -quiet)

{ 
    $status["Results"] = "Active"
} 
else 
{ 
    $status["Results"] = "Inactive" 
}
New-Object -TypeName PSObject -Property $status -OutVariable serverStatus
$collection += $serverStatus

}
$collection | Export-Csv C:\install\ServerStatus.csv -NoTypeInformation





$servers = import-csv 'config-network devicetest.csv'
$collection = $()
foreach ( $IPAddress in $servers)
{
$status = @{ "ServerName" = $name; "TimeStamp" = (Get-Date -f s); "Results"="" }
if (Test-Connection -IPAddress $IPAddress -Count 2 -ea 0 -quiet)
{ 
    $status["Results"] = "Active"
} 
else 
{ 
    $status["Results"] = "Inactive" 
}
New-Object -TypeName PSObject -Property $status -OutVariable serverStatus
$collection += $serverStatus

}
$collection | Export-Csv .\ServerStatus.csv -NoTypeInformation




#custom objects
$ServersList=Get-ADComputer -Filter {OperatingSystem -Like "Windows *Server*"} -Property * | sort-object name |  foreach { 
    $obj = "" | select name,OU
    [string]$obj.name = $_.name
    [string]$obj.ou = $_.OU
    $obj
}







################################################################################################################

$ServersList=Get-ADComputer -Filter {OperatingSystem -Like "Windows *Server*"} -Property * | sort-object name |  foreach { 
    $obj = "" | select name,distinguishedname,lastlogondate
    [string]$obj.name = $_.name
    [string]$obj.distinguishedname = $_.distinguishedname.split(",")[2]
#    [string]$obj.distinguishedname = $_.distinguishedname
    [string]$obj.lastlogondate = $_.lastlogondate
    $obj
}

$Collection = $()

foreach ($server in $ServersList){
              
            $status = @{ "ServerName" = $server.name ; "distinguishedname" = $server.distinguishedname ; `
            "lastlogondate" = $server.lastlogondate; "TimeStamp" = (Get-Date -f s); "Results"=""}

if (Test-Connection -computername $server.name -Count 2 -ea 0 -quiet)

{ 
    $status["Results"] = "Active"
} 
else 
{ 
    $status["Results"] = "Inactive" 
}
New-Object -TypeName PSObject -Property $status -OutVariable serverStatus
$collection += $serverStatus

}
$collection | Export-Csv C:\install\ServerStatus2.csv -NoTypeInformation


###########################################################################################################################
###########################################################################################################################
# Code to take the compiled list and "test" connection
#
# Most code from http://stackoverflow.com/questions/25757258/test-connection-output-to-csv-file-with-hostname-and-ipaddress
#
# Pulls all server obects from AD and adds the collection to a csvfile
# Modify this line to save CSV file "Export-Csv C:\install\ServerStatus2.csv -NoTypeInformation"
###########################################################################################################################
###########################################################################################################################

$ServersList=Get-ADComputer -Filter {OperatingSystem -Like "Windows *Server*"} -Property * | sort-object name |  foreach { 
    $obj = "" | select Name,DistinguishedName,LastLogonDate
    [string]$obj.Name = $_.Name
#    [string]$obj.distinguishedname = $_.distinguishedname.split([string[]]"$Header,", [StringSplitOptions]"None")[2]
    [string]$obj.DistinguishedName = $_.DistinguishedName
    [string]$obj.LastLogonDate = $_.LastLogonDate
    [string]$obj.OperatingSystem = $_.OperatingSystem
    $obj
}

$Collection = $()

foreach ($server in $ServersList){
              
            $status = @{ "ServerName" = $server.name ; "Operating Sytem" = $server.OperatingSystem ; "OU" = $server.DistinguishedName ; `
            "Last Logon Date" = $server.LastLogonDate ; "ReportTime" = (Get-Date -f s) ; "Results" = ""}

if (Test-Connection -computername $server.name -Count 3 -ea 0 -quiet)

{ 
    $status["Results"] = "Active"
} 
else
{ 
    $status["Results"] = "Inactive"
}
New-Object -TypeName PSObject -Property $status -OutVariable ServerStatus
$collection += $ServerStatus

}
$collection | Export-Csv C:\install\ServerStatus2.csv -encoding "UTF8" -NoTypeInformation

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

$ServersList=Get-ADComputer -Filter {OperatingSystem -Like "Windows *Server*"} -Property * | sort-object name |  foreach { 
    $obj = "" | select Name,DistinguishedName,LastLogonDate,OperatingSystem,CanonicalName
    [string]$obj.Name = $_.Name
    [string]$obj.OperatingSystem = $_.OperatingSystem
#    [string]$obj.distinguishedname = $_.distinguishedname.split([string[]]"$Header,", [StringSplitOptions]"None")[2]
    [string]$obj.DistinguishedName = $_.DistinguishedName
    [string]$obj.LastLogonDate = $_.LastLogonDate
    [string]$obj.CanonicalName = $_.CanonicalName
        $obj
}

$Collection = $()

foreach ($server in $ServersList){
              
            $status = @{ "ServerName" = $server.name ; "OU" = $server.DistinguishedName ; `
            "Last Logon Date" = $server.LastLogonDate ; "ReportTime" = (Get-Date -f s) ; "Results"="" ; `
            "OperatingSystem" = $server.OperatingSystem ; "CanonicalName" = $server.CanonicalName}

if (Test-Connection -computername $server.name -Count 3 -ea 0 -quiet)

{ 
    $status["Results"] = "Active"
} 
else 
{ 
    $status["Results"] = "Inactive" 
}
New-Object -TypeName PSObject -Property $status -OutVariable ServerStatus
$collection += $ServerStatus

}
$collection | Export-Csv C:\install\ServerStatus4.csv -encoding "UTF8" -NoTypeInformation

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

$ServersList=Get-ADComputer -Filter {OperatingSystem -Like "Windows *Server*"} -Property * | sort-object name | `
foreach { 
    $obj = "" | select Name,DistinguishedName,LastLogonDate,OperatingSystem
    [string]$obj.Name = $_.Name
    [string]$obj.OperatingSystem = $_.OperatingSystem
#    [string]$obj.distinguishedname = $_.distinguishedname.split([string[]]"$Header,", [StringSplitOptions]"None")[2]
    [string]$obj.DistinguishedName = $_.DistinguishedName
    [string]$obj.LastLogonDate = $_.LastLogonDate
        $obj
}

$Collection = $()

foreach ($server in $ServersList){
              
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
$collection += $ServerStatus

}
$collection | Export-Csv C:\install\ServerStatus5.csv -encoding "UTF8" -NoTypeInformation

