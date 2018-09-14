## Define the username that’s locked out
$Username = 'ussplink'

## Find the domain controller PDCe role
$Pdce = (Get-AdDomain).PDCEmulator

## Build the parameters to pass to Get-WinEvent
$GweParams = @{
     'Computername' = $Pdce
     'LogName' = 'Security'
     'FilterXPath'' = "*[System[EventID=4740] and EventData[Data[@Name='TargetUserName']='$Username']]"
}

## Query the security event log
$Events = Get-WinEvent @GweParams

$DomainControllers = Get-ADDomainController -Filter *

Foreach($DC in $DomainControllers)

 {

Get-ADUser -Identity brwilliams -Server $DC.Hostname `

-Properties AccountLockoutTime,LastBadPasswordAttempt,BadPwdCount,LockedOut

}

Get-Eventlog -ComputerName DC01 “Security” -InstanceID “4740” -Message *”USERNAME”* | Format-List Timegenerated, Message
