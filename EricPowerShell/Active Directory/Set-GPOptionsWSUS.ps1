#############################################################################
##
## Set Group Policy WSUS Update options

set-GPRegistryValue -name 'SSI GROUP WSUS Server Policy'-Key HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\windows\WindowsUpdate\AU -ValueName 'auoptions' -type dword -value 4

set-GPRegistryValue -name 'SSI GROUP WSUS Server Policy'-Key HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\windows\WindowsUpdate\AU -ValueName 'auoptions' -type dword -value 3