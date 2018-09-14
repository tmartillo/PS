###
# start/stop SSH service on all hosts in a cluster
##

$GetCluster = Get-Cluster | Select-Object name | Sort-Object Name | more

switch (Read-Host "Do you want to START or STOP SSH? Type START or STOP") {
    START { $GetCluster
        
        $Cluster = Read-Host -Prompt "Enter name of cluster"
        
        Get-cluster -name "$Cluster" | Get-VMHost | 
            ForEach-Object {
                Start-VMHostService -HostService ($_ | Get-VMHostService | Where-Object { $_.Label -eq "SSH"})
            } 
        }
    STOP { $GetCluster
        
        $Cluster = Read-Host -Prompt "Enter name of cluster"
        
        Get-cluster -name "$Cluster" | Get-VMHost | 
            ForEach-Object {
                Stop-VMHostService -HostService ($_ | Get-VMHostService | Where-Object { $_.Label -eq "SSH"}) -Confirm:$false
            }
        }
    Default {"Invalid Entry"}

}