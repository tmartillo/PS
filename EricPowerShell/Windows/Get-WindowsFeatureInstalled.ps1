##
## Run the following code to get the Roles and Features installed
##

$server = "SERVERNAMEHERE"

Get-WindowsFeature -ComputerName $server | Where-Object InstallState -eq Installed | Format-Table -AutoSize