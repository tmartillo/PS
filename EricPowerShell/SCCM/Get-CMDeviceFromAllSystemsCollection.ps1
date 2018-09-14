#Launch Configuration Manager Console - win2k8 and higher
$ConfigMgrModulePath="C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager\ConfigurationManager\ConfigurationManager.psd1"
$ConfigMgrSiteCode=“AT1:”
Import-Module $ConfigMgrModulePath
Set-Location $ConfigMgrSiteCode

#Array to collect all servers in NASA sites
$SCCMArray=Get-CMDevice -CollectionName "clients | no" | Where-Object {$_.ADSiteName -eq "USA009" -and $_.ADSiteName -eq "CAN011" `
-and $_.ADSiteName -eq "CAN004" -and $_.ADSiteName -eq "CAN031" -and $_.ADSiteName -eq "CAN030" `
-and $_.ADSiteName -eq "CAN001"} | `
Select-Object Name, ADSiteName, DeviceOS, IsActive, IsClient