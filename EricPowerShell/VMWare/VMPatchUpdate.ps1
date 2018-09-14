###VMWare patch update using VMWare Udate Manager
Add-PSSnapin VMware.VumAutomation
#This section scans the esx hosts against the Critcal Host Pathces baseline
$file = 'C:\temp\hosts.txt'
$scanhosts = 'C:\temp\scanhosts.txt'
Get-VMHost | ft name -auto -HideTableHeaders | out-file -FilePath $file -encoding UTF8
get-content -path $file | foreach {$_.trimend()} | set-content $scanhosts
$scanhosts = get-content -path 'C:\temp\scanhosts.txt'
$baseline = get-baseline -name 'Critical Host Patches (Predefined)'
$NonComp = get-content -path 'C:\Temp\NonComp.txt'
$Remediate = 'C:\Temp\Remdiate.txt'

foreach ($item in $scanhosts) 
    {
        Scan-Inventory -Entity $item -updatetype hostpatch -RunAsync
    }

foreach ($item in $scanhosts)
    {
        Get-Compliance -entity $item -Baseline $baseline -ComplianceStatus 'NotCompliant' | `
        ft entity -hidetableheaders 
    }

get-content -path $NonComp

#This section stages patches on the host(s):

foreach ($item in $NonComp)
    {
        Stage-Patch -Entity $item -Baseline $baseline -RunAsync -Confirm:$false
    }

#This section moves VM's on a clustered host(s)

Get-VM -Location "VMHost" | Move-VM -Destination (Get-VMHost "VMHost")

#This section remediates the hosts(s):

foreach ($item in $scahosts)
    {
       Remediate-Inventory -Entity $item -baseline $baseline -HostRetryDelaySeconds 120 -HostNumberOfRetries 2 -HostPreRemediationPowerAction 'DoNotChangeVMsPowerState' -ClusterDisableFaultTolerance:$true -ClusterDisableHighAvailability:$true -confirm:$false 
    }


##########################################################################################################


$hosts = get-content -path 'C:\temp\hosts.txt'
$upgrade = get-baseline -name 'Dell-Custom-ESXi-5.5.U3'
$upgrade = get-baseline -name 'Upgrade to ESXi v5.5 U3'
$upgrade = Get-Baseline -name 'Cisco UCS vSphere 5.5 u3'

foreach ($item in $hosts) 
    {
        Scan-Inventory -Entity $item -updatetype HostUpgrade -RunAsync
    }

#This section stages patches on the host(s):

foreach ($item in $hosts)
    {
        Stage-Patch -Entity $item -Baseline $upgrade -RunAsync -Confirm:$false
    }

#This section remediates the hosts(s):

foreach ($item in $hosts)
    {
       Update-Entity -Entity $item -baseline $upgrade -HostRetryDelaySeconds 60 -HostNumberOfRetries 3 -HostPreRemediationPowerAction 'DoNotChangeVMsPowerState' -HostIgnoreThirdPartyDrivers:$true -confirm:$false -RunAsync 
    }