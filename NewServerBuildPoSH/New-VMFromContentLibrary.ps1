<#
.Synopsis
   	Uses Content Library Template to Deploy new VM
.DESCRIPTION
    This will modify an existing Customization Specification and deploy a new VM from the content library
.EXAMPLE
    Change the variables to suit your needs and paste into PoSH shell
.NOTES
   	Version 1.0 - Initial Script
   	Written by Eric Talamantes
   	Date: 11.30.2017

#>

$newvmname = 'NEWVMHERE'
$contentlibraryitem = 'Windows_Server_2012_R2_Template_Gold_HW_Ver_6.5'
$vmhost = 'usssusesx001.nasa.group.atlascopco.com'
$spec = 'SSI DC Serv Ops USA009 VLAN1501'
$ip = '10.0.32.229'
$submask = '255.255.255.192'
$gw = '10.0.32.193'
$dns = '10.128.40.115','10.128.30.115'
$disk = 'thin'
$datastore = 'Texas-Garland-USA009-DatastoreCluster'
$resourcepool = 'test'
$notes = 'CRD #PutCRDNumberHERE'

Get-OSCustomizationSpec -Name $spec | Get-OSCustomizationNicMapping | Set-OSCustomizationNICMapping -IpMode 'UseStaticIP' -IpAddress $ip -SubnetMask $submask -DefaultGateway $gw -DNS $dns
New-VM -name $newvmname -vmhost $vmhost -DiskStorageFormat $disk -ContentLibraryItem $contentlibraryitem -DataStore $datastore -ResourcePool $resourcepool
Set-VM -VM $newvmname –OSCustomizationSpec $spec -Notes $notes -Confirm:$false
Get-NetworkAdapter $newvmname | Set-NetworkAdapter -StartConnected:$true -Confirm:$false
Start-VM $newvmname