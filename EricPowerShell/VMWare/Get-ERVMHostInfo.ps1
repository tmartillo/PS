Get-Cluster | Get-VMHost |

Select-Object Name,

    @{N='CPU GHz Capacity';E={[math]::Round($_.CpuTotalMhz/1000,2)}},

    @{N='CPU GHz Used';E={[math]::Round($_.CpuUsageMhz/1000,2)}},

    @{N='CPU GHz Free';E={[math]::Round(($_.CpuTotalMhz - $_.CpuUsageMhz)/1000,2)}},

    @{N='Memory Capacity GB';E={[math]::Round($_.MemoryTotalGB,2)}},

    @{N='Memory Used GB';E={[math]::Round($_.MemoryUsageGB,2)}},

    @{N='Memory Free GB';E={[math]::Round(($_.MemoryTotalGB - $_.MemoryUsageGB),2)}},
    
    @{N='Parent';E={$_.Parent}} | Sort-Object Parent

    Export-Csv -Path C:\report.csv -NoTypeInformation -UseCulture