<#
.Synopsis
   	Uses vmotion to migrate guest to another esxi hostwhen no drs is available
.DESCRIPTION
    This will migrate vm's using txt file with VM's
.EXAMPLE
    Change the variables to suit your needs and paste into PoSH shell
.NOTES
   	Version 1.0 - Initial Script
   	Written by Eric Talamantes
       Date: 01.03.2018
#>

# Modify this to fit your needs for the file location
$VMGuests = Get-content "C:\temp\vmguest2.txt"
# Modify this to the new esx host
$NewHost = "usssusesx003.nasa.group.atlascopco.com"

ForEach ($VM in $VMGuests)

    {Move-VM $VM -Destination $NewHost}