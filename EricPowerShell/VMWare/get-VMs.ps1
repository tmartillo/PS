###############################################################################################
##
## Get-VM will get list of all VM's
##
##
################################################################################

get-Viserver @('usssusvc010','usssusvc001';'ssisusvc0005','ssdsbrvc0001');

get-vm | Select-Object name,powerstate,@{N="IPAddress"; E={$_.Guest.IPAddress[0]}},@{N="DnsName"; E={$_.ExtensionData.Guest.Hostname}} | Sort-Object name | Format-Table -AutoSize
