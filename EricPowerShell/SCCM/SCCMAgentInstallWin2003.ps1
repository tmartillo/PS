#Pre-Requisite you must have installed bits2.5 first (bits2.5install.ps1)
#You must be logged into SSISUSSCCMA2
#This will only install for Windows Server 2003

#Launch Configuration Manager Console - win2k3
$ConfigMgrModulePath="C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1"
$ConfigMgrSiteCode=“AT2:”
Import-Module $ConfigMgrModulePath
Set-Location $ConfigMgrSiteCode

#SCCM client install for 2003 and greater
$sccmtargets="C:\temp\bitssccmtargets.txt"
ForEach($server in (Get-Content $sccmtargets))
        {
            Install-CMClient -DeviceName $server -SiteCode "at2" -ForceReinstall $True -AlwaysInstallClient $True -IncludeDomainController $false -verbose
        }
