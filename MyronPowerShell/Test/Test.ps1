#region User Specified WSUS Information 
$WSUSServer = 'SSISUSWSUS001' 
 
#Accepted values are "80","443","8350" and "8351" 
$Port = 80  
$UseSSL = $False 
 
#Specify when a computer is considered stale 
$DaysComputerStale = 30  
 
#Send email of report 
[bool]$SendEmail = $FALSE 
#Display HTML file 
[bool]$ShowFile = $TRUE 
#endregion User Specified WSUS Information 
 
#region User Specified Email Information 
$EmailParams = @{ 
    To = 'myron.grade@external.atlascopco.com' 
    From = 'WSUSReport@domain.local'     
    Subject = "$WSUSServer WSUS Report" 
    SMTPServer = 'exchange.domain.local' 
    BodyAsHtml = $True 
} 
#endregion User Specified Email Information