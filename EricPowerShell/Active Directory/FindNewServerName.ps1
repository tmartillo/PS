$famcode = Read-Host -Prompt "Enter name the fam code of the server "
Write-Output " There are 3 types of servers: 
FS - file server
IS - infrstructure server
AS - application server"
$ServerType = Read-Host -Prompt "Enter the server type ( FS, IS or AS) "

Write-Output "Country Codes: 
US - United States
CA - Canada
MX - Mexico
PE - Peru
VE - Venezuela
CH - Chile
BR - Brazil"
$CountryCode = Read-Host -Prompt "Enter the country code "

	Write-Output "Looking for existing servers by the name "$famcode"s"$countrycode""$servertype""
	$tempvar = "$famcode s $countrycode$servertype*"
	$tempvar = $tempvar -replace '\s',''
#	Clear-Host
	Write-Output "Current Servers prefixed by $tempvar"
	
Get-Command -Name 'Get-ADComputer'
Get-ADComputer usssusfs009
	
$newserver = Read-Host -Prompt "Enter the server name you want "	
	#foreach( $ip in $newserver) {
		if (test-connection $newserver -count 1 -quiet) {
			Write-Host " " 
			write-host  "Server name $newserver is in USE! Please choose another." -foreground red
			Write-Host " " 
	
		} else {
			Write-Host " " 
			write-host  "Server name $newserver is available. You are clear to use this name. " -foreground green
			Write-Host " " 
		}
	#}