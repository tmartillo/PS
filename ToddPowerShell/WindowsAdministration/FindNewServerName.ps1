
$famcode = Read-Host -Prompt "Enter name the fam code of the server "
Write-Output " There are 4 types of servers: 
fs - File server
is - Infrstructure server
as - Application server
ww - Web Server"
$ServerType = Read-Host -Prompt "Enter the server type ( fs, is or as) "

Write-Output "Country Codes: 
us - United States
ca - Canada
mx - Mexico
PE - Peru
VE - Venezuela
CH - Chile
BR - Brazil"
$CountryCode = Read-Host -Prompt "Enter the country code "

	Write-Output "Looking for existing servers by the name "$famcode"s"$countrycode""$servertype""
	$tempvar = "$famcode s $countrycode$servertype*"
	$tempvar = $tempvar -replace '\s',''
	Clear-Host
	Write-Output "Current Servers prefixed by $tempvar"
	
	get-adcomputer -Filter "Name -like '$tempvar'" | Format-Table Name -Wrap -AutoS
Write-Host " NOTE: The standard naming convention is 
ssi s us as 0000
 |  |  |  |  |
 |  |  |  |  4 digit server
 |  |  |  server type
 |  |  country code
 |  server designation
 fam code  
 "	-ForegroundColor magenta
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
	write-host "Press any key to continue..."
	$host.UI.RawUI.ReadKey()