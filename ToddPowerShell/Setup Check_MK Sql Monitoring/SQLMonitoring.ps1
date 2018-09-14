# Use this file to copy the mssql agent to a remote server and then restart the check_MK_agent service
# Run this by running sqlmonitoring.ps1 from the the path it sits in.  
# This requires the file mssql.vbs to be in the same folder as the script. 

$Server = Read-Host -Prompt 'Input your server  name'

Write-Host "You input server '$Server'"

Copy-Item -Path .\mssql.vbs -Destination "\\$server\c$\Program Files (x86)\check_mk\plugins\mssql.vbs";

# Restart the Service
Get-Service -Name check_mk_agent -Computername $Server | stop-service
Start-Sleep -s 5
Get-Service -Name check_mk_agent -Computername $Server | start-service
