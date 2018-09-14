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
