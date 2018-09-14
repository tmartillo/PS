<#
.Synopsis
   	Pulls MPIO information on windows server 2012
.DESCRIPTION
    Pulls windows features to see if MPIO installed
.EXAMPLE
    Change the variables to suit your needs and paste into PoSH shell
.NOTES
   	Version 1.0 - Initial Script
   	Written by Eric Talamantes
   	Date: 02.22.2017

#>

Get-WindowsOptionalFeature –Online –FeatureName MultiPathIO

Get-MSDSMGlobalDefaultLoadBalancePolicy

Set-MSDSMGlobalDefaultLoadBalancePolicy -Policy RR
