#Enter the iDRAC IP Address of the Server 
$ipaddress=Read-Host -Prompt "Enter the IP Address" 
 
 
#Enter the Username and password  
$username=Read-Host -Prompt "Enter the Username" 
$password=Read-Host -Prompt "Enter the Password" -AsSecureString 
 
$credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist $username,$password 
 
# Setting the CIM Session Options 
$cimop=New-CimSessionOption -SkipCACheck -SkipCNCheck  -Encoding Utf8 -UseSsl  
$session=New-CimSession -Authentication Basic -Credential $credentials -ComputerName $ipaddress -Port 443 -SessionOption $cimop -OperationTimeoutSec 10000000  
echo $session 
 
$System=Get-CimInstance -CimSession $session -ResourceUri "http://schemas.dell.com/wbem/wscim/1/cim-schema/2/DCIM_SystemView" 
$Svctag=$System.ServiceTag 
Write-Host "Service Tag :"  $Svctag