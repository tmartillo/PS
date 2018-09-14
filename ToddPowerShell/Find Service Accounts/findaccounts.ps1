$Servers = get-content .\servers.txt
foreach ($Server in $Servers) {
    echo $Server >> C:\temp\services.txt 
write-host $Server >> C:\temp\services.txt
#Get-WMIObject Win32_Service -ComputerName $Server | Sort-Object -Property StartName | Format-Table Name, StartName >> c:\temp\services.txt

gwmi win32_service | where {$_.Startname -ne "localsystem"} | where {$_.Startname -ne "NT Authority\localservice"} | where {$_.Startname -ne "NT AUTHORITY\NetworkService"} | select name,startname  >> c:\temp\services.txt

}
