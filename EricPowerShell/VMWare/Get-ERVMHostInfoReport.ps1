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
$report = @()

foreach($cluster in Get-Cluster){
    $esx = $cluster | Get-VMHost
    $ds = Get-Datastore -VMHost $esx

    $row = "" | Select-Object VCName,DCName,ClusterName,"Total Physical Memory (GB)",
                "Configured Memory (GB)","Available Memory (GB)",
                "Total CPU (Mhz)","Configured CPU (Mhz)",
                "Available CPU (Mhz)","Total Disk Space (GB)",
                "Configured Disk Space (GB)","Available Disk Space (GB)",
                "ESXi Host Count","ESXi CPU Socket Count"

        $row.VCname = $cluster.Uid.Split(':@')[1]

        $row.DCname = (Get-Datacenter -Cluster $cluster).Name
    
        $row.Clustername = $cluster.Name
    
        $row."Total Physical Memory (GB)" = ($esx | Measure-Object -Property MemoryTotalGB -Sum).Sum
    
        $row."Configured Memory (GB)" = ($esx | Measure-Object -Property MemoryUsageGB -Sum).Sum
    
        $row."Available Memory (GB)" = ($esx | Measure-Object -InputObject {$_.MemoryTotalGB - $_.MemoryUsageGB} -Sum).Sum
    
        $row."Total CPU (Mhz)" = ($esx | Measure-Object -Property CpuTotalMhz -Sum).Sum
    
        $row."Configured CPU (Mhz)" = ($esx | Measure-Object -Property CpuUsageMhz -Sum).Sum
    
        $row."Available CPU (Mhz)" = ($esx | Measure-Object -InputObject {$_.CpuTotalMhz - $_.CpuUsageMhz} -Sum).Sum

        $row."Total Disk Space (GB)" = ($ds | Measure-Object -Property CapacityGB -Sum).Sum

        $row."Configured Disk Space (GB)" = ($ds | Measure-Object -InputObject {$_.CapacityGB - $_.FreeSpaceGB} -Sum).Sum
    
        $row."Available Disk Space (GB)" = ($ds | Measure-Object -Property FreeSpaceGB -Sum).Sum

        $row."ESXi Host Count" = ($esx.count)

        $row."ESXi CPU Socket Count" = (($esx | Get-View).summary.hardware.NumCpuPkgs)

        $report += $row
}

$report | Export-Csv "C:\Temp\Cluster-Report.csv" -NoTypeInformation -UseCulture