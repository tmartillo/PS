<#
.Synopsis
   	Gathers MEM, CPU, Datastore, Socket Count, and ESXi host count per cluster
.DESCRIPTION
    Gathers MEM, CPU, Datastore, Socket Count, and ESXi host count per cluster
.EXAMPLE
    Connect to vCenter get-viserver and run the code
.NOTES
    Gathered from https://communities.vmware.com/thread/303270
   	Version 1.0 - Initial Script
   	Written by Eric Talamantes
       Date: 1.23.2018

#>

foreach($cluster in Get-Cluster){
    $esx = $cluster | Get-VMHost
    $ds = Get-Datastore -VMHost $esx

    $cluster | Select-Object @{N="VCname";E={$cluster.Uid.Split(':@')[1]}},

        @{N="DCname";E={(Get-Datacenter -Cluster $cluster).Name}},
    
        @{N="Clustername";E={$cluster.Name}},
    
        @{N="Total Physical Memory (GB)";E={($esx | Measure-Object -Property MemoryTotalGB -Sum).Sum}},
    
        @{N="Configured Memory GB";E={($esx | Measure-Object -Property MemoryUsageGB -Sum).Sum}},
    
        @{N="Available Memory (GB)";E={($esx | Measure-Object -InputObject {$_.MemoryTotalGB - $_.MemoryUsageGB} -Sum).Sum}},
    
        @{N="Total CPU (Mhz)";E={($esx | Measure-Object -Property CpuTotalMhz -Sum).Sum}},
    
        @{N="Configured CPU (Mhz)";E={($esx | Measure-Object -Property CpuUsageMhz -Sum).Sum}},
    
        @{N="Available CPU (Mhz)";E={($esx | Measure-Object -InputObject {$_.CpuTotalMhz - $_.CpuUsageMhz} -Sum).Sum}},
    
        @{N="Total Disk Space (GB)";E={($ds | Measure-Object -Property CapacityGB -Sum).Sum}},

        @{N="Configured Disk Space (GB)";E={($ds | Measure-Object -InputObject {$_.CapacityGB - $_.FreeSpaceGB} -Sum).Sum}},
    
        @{N="Available Disk Space (GB)";E={($ds | Measure-Object -Property FreeSpaceGB -Sum).Sum}},

        @{N="ESXi Host Count";E={($esx.count)}},

        @{N="ESXi CPU Socket Count";E={(($esx | Get-View).summary.hardware.NumCpuPkgs)}}
}
