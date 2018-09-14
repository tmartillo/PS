<#
.Synopsis
   	Pulls vRanger savepoints and deletes them for the following week
.DESCRIPTION
    Pulls savepoints from Production and Test Repositories
    Deletes all of the savepoints
.EXAMPLE
    Change the variables to suit your needs and paste into PoSH shell
.NOTES
   	Version 1.0 - Initial Script
   	Written by Eric Talamantes
   	Date: 12.12.2017

#>

Add-PSSnapin vranger.api.powershell
$savepoints = Get-Repository | Get-RepositorySavePoint
Remove-SavePoint -SavePointsToRemove $savepoints