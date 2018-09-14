#You must be logged into SSISUSSCCMA1
#This will only install for Windows Server 2008 and newer OS
#Launch Configuration Manager Console - win2k8 and higher
$ConfigMgrModulePath="C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager\ConfigurationManager\ConfigurationManager.psd1"
$ConfigMgrSiteCode=“AT1:”
Import-Module $ConfigMgrModulePath
Set-Location $ConfigMgrSiteCode

#SCCM client install for 2008 and greater
$sccmtargets="C:\temp\sccmtargets.txt"
ForEach($server in (Get-Content $sccmtargets))
        {
            Install-CMClient -DeviceName $server -SiteCode "at1" -ForceReinstall $True -AlwaysInstallClient $True -IncludeDomainController $false -verbose
        }
