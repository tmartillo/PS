#Test connection of servers
#
$ServersList=Get-Content 'C:\temp\ServersList.txt'
$status=foreach ($server in $ServersList){
if (Test-Connection -computername $server -Count 3 -ea 0 -Verbose)
    { 
    "$Server Active"
    } 
    else 
    { 
    "$Server Inactive" 
    }
}
$status