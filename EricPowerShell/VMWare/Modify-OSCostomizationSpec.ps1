# This will modify an existing Customization Specification

$spec = 'SSI DC Serv Ops USA009 VLAN1501'
$ip = '10.0.32.217'
$submask = '255.255.255.192'
$gw = '10.0.32.193'
$dns = '10.128.40.115','10.128.30.115'
Get-OSCustomizationSpec -Name $spec | Get-OSCustomizationNicMapping | Set-OSCustomizationNICMapping -IpMode 'UseStaticIP' -IpAddress $ip -SubnetMask $submask -DefaultGateway $gw -DNS $dns