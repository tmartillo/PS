<#
.Synopsis
   	Pulls vRanger savepoints and deletes them for the following week
.DESCRIPTION
    Pulls savepoints from Test Repositories
    Deletes all of the savepoints
.EXAMPLE
    Change the variables to suit your needs and paste into PoSH shell
.NOTES
   	Version 1.0 - Initial Script
   	Written by Eric Talamantes
   	Date: 02.22.2017

#>

Add-PSSnapin vranger.api.powershell
$savepoints = Get-Repository -Id '29e7c16a-c8fd-4f28-b588-0e4257c5fd60' | Get-RepositorySavePoint
Remove-SavePoint -SavePointsToRemove $savepoints