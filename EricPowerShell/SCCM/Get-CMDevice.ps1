#Launch Configuration Manager Console - win2k8 and higher
$ConfigMgrModulePath="C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager\ConfigurationManager\ConfigurationManager.psd1"
$ConfigMgrSiteCode=“AT1:”
Import-Module $ConfigMgrModulePath
Set-Location $ConfigMgrSiteCode

#Get SCCM device's by ADSiteName, DeviceOS, IsActive, IsClient, LastActiveTime, Name, Status
$sccmtargets="C:\temp\sccmtargets.txt"
$SCCMArray=ForEach($server in (Get-Content $sccmtargets))
        {
            Get-CMDevice -name $server | Select-Object Name, ADSiteName, DeviceOS, IsActive, IsClient, LastActiveTime
        }
$SCCMArray | ft