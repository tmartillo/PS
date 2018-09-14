#############################################################################
## Set Group Policy WSUS Update options                                    ##
############################################################################# 

#Setting for auto install once CAB is approved
Set-GPRegistryValue -name 'SSIUS GROUP WSUS Server Policy'-Key HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\windows\WindowsUpdate\AU -ValueName 'auoptions' -type dword -value 4

#setting to turn off auto install once the patch's have been applied
Set-GPRegistryValue -name 'SSIUS GROUP WSUS Server Policy'-Key HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\windows\WindowsUpdate\AU -ValueName 'auoptions' -type dword -value 3

#Retrieve GP policy settings
Get-GPRegistryValue -name 'SSIUS GROUP WSUS Server Policy'-Key HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\windows\WindowsUpdate\AU

#Setting to set time of automatic update install
Set-GPRegistryValue -name 'SSIUS GROUP WSUS Server Policy'-Key HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\windows\WindowsUpdate\AU -ValueName 'ScheduledInstallTime' -type dword -value 16

#Setting to set day of install
Set-GPRegistryValue -name 'SSIUS GROUP WSUS Server Policy'-Key HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\windows\WindowsUpdate\AU -ValueName 'ScheduledInstallDay' -type dword -value 1

