##########################################
##
## Script gathers esxi host version
##
##########################################

(Get-View –ViewType HostSystem -Property Name,Config.Product | select Name,{$_.Config.Product.FullName} `
| Sort-Object '$_.Config.Product.FullName' | ft -AutoSize).count

##########################################

Get-View -ViewType HostSystem -Property Name,Config.Product | foreach {$_.Name, $_.Config.Product}