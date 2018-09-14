## Gathers iDRAC info from ESX host *Add function Get-VMHostWSManInstance
$VMhost = get-content -path 'C:\temp\scanhosts.txt'

$IdracArray = $()
foreach ($item in $VMhost)
    {
        $info = Get-VMHostWSManInstance -VMHost (Get-VMHost $item) -ignoreCertFailures -class OMC_IPMIIPProtocolEndpoint
    }


$IdracArray += $info
$IdracArray = add-member -MemberType NoteProperty -Name "iDRAC IP" -value $VMhost.IPv4Address
# You can remove the -ignoreCertFailures flags if your systems have trusted certs.
# This should return you the configuration of your iLO/iDrac, which includes IP address, like so:
$info.IPv4Address