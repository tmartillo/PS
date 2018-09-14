# Load Windows PowerShell cmdlets for PoshWSUS/GPO/ACtiveDirectory
Import-module ACtiveDirectory
Import-Module PoshWSUS
Import-Module UpdateServices
Connect-PSWSUSServer ssisuswsus001 8530
Get-PSWSUSClientsInGroup -name 'Unassigned Computers' | Add-PSWSUSClientToGroup -group 'Production'