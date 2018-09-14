####################################################################
##Run these commands after deploying a Windows Server 2016 Server
#in Powershell
####################################################################
setx PSModulePath "$env:PSModulePath;c:\scripts\modules" -m
Set-ExecutionPolicy RemoteSigned -Force

# disable firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled 'False'

# Create new directories if not already present
New-Item -Path "c:\Scripts" -Name "Modules" -ItemType "directory"
New-Item -Path "c:\" -Name "Temp" -ItemType "directory"
New-Item -Path "c:\" -Name "Install" -ItemType "directory"

#disable UAC
New-ItemProperty -Path "HKLM:Software\Microsoft\Windows\CurrentVersion\policies\system" -Name "EnableLUA" -PropertyType "DWord" -Value 0 -Force

#Installs telnet-client for testing
Add-WindowsFeature Telnet-Client

#Disable IPv6
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\" -Name "DisabledComponents" -Value "0xff" -PropertyType "DWord" -Force

#disable Server Manager 2016
Get-ScheduledTask servermanager | Disable-ScheduledTask

#Add Proxy server to Server
$regKey2="HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
$proxyServerToDefine = "dfw1.sme.zscaler.net:10078"
Set-ItemProperty -Path $regKey2 ProxyOverride -Value "<local>"
Set-ItemProperty -path $regKey2 ProxyServer -Value $proxyServerToDefine
Set-ItemProperty -path $regKey2 ProxyEnable -value 1

#fixes the Windows Security updates issue where it never downloads
netsh winhttp set proxy dfw1.sme.zscaler.net:10078

# Disable automatically detect settings in IE
$reg3key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
$keyname = "AutoDetect"
$reg3keyvalue = "0"
New-ItemProperty -Path $reg3key -Name $keyname -Value $reg3keyvalue ` -PropertyType DWORD -Force | Out-Null

# Launches IE in order for the update-help to run successfully
Invoke-Item "C:\Program Files\Internet Explorer\iexplore.exe"

#updates the PowerShell help files
Update-Help

#Gpupdate run this after you move the server to the proper OU
gpupdate /force

# Updated to download msi directly from Check_MK URL ensuring we install the latest agent
Invoke-WebRequest -Uri 'http://ssisusckmk01.nasa.group.atlascopco.com/us/check_mk/agents/windows/check_mk_agent.msi' -OutFile 'C:\temp\check_mk_agent.msi'
Start-Process msiexec.exe -Wait -ArgumentList '/I C:\Temp\Check_mk_agent.msi /quiet'

#Updated to Install Symantec Client
Start-Process msiexec.exe -Wait -ArgumentList "/I \\usssusfs0001\software\Software\NAV_CorpEd\SEP_12.1_RU6_MP5_Servers_x64_nodefs\Sep64.msi /quiet"

#Updated to Install Tanium Client
Start-Process msiexec.exe -Wait -ArgumentList "/I \\usssusfs0001\software\Software\Tanium\installtanium.msi /quiet"

#Run after you install security updates to force run of .Net Runtime Optimization Service
#%windir%\microsoft.net\framework64\v4.0.30319\ngen.exe update /Force
#%windir%\microsoft.net\framework64\v4.0.30319\ngen.exe executequeueditems

#Sets pagefile to 4gb if not already set
$computersys = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges;
$computersys.AutomaticManagedPagefile = $False;
$computersys.Put();
$pagefile = Get-WmiObject -Query "Select * From Win32_PageFileSetting Where Name like '%pagefile.sys'";
$pagefile.InitialSize = 4096;
$pagefile.MaximumSize = 4096;
$pagefile.Put();