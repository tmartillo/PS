<#
.Synopsis
   	Install WSUS and compenents needed
.DESCRIPTION
    This will install WSUS and all necessary components
.EXAMPLE
    Change the variables to suit your needs and paste into PoSH shell
.NOTES
   	Version 1.0 - Initial Script
   	Written by Eric Talamantes
   	Date: 02.26.2018

#>

#Install WSUS bits:
Install-WindowsFeature -Name UpdateServices -IncludeManagementTools

#Create directory and configure database:
New-Item -Path D: -Name WSUS -ItemType Directory
Set-Location 'C:\Program Files\Update Services\Tools'
.\WsusUtil.exe postinstall CONTENT_DIR=D:\WSUS
#note - CPU stays super high for a few minutes after install appears to complete. Just be patient.

#Inspect the installation:
Invoke-BpaModel -ModelId Microsoft/Windows/UpdateServices

#Run BPA (Best Practices Analyzer):
Get-BpaResult -ModelId Microsoft/Windows/UpdateServices | Select-Object Title,Severity,Compliance | Format-List

#Configure Language and setup categories
#Get WSUS Server Object:
$wsus = Get-WSUSServer

#Connect to WSUS server configuration:
$wsusConfig = $wsus.GetConfiguration()

#Set WSUS proxy information
$proxyname = "dfw1.sme.zscaler.net"
$proxyport = 10078
$wsusConfig.proxyname = $proxyname
$wsusConfig.ProxyServerPort = $proxyport
$wsusConfig.UseProxy = $true

#Set to download updates from Microsoft Updates:
Set-WsusServerSynchronization –SyncFromMU

#Set Update Languages to English and save configuration settings:
$wsusConfig.AllUpdateLanguagesEnabled = $false 
$wsusConfig.SetEnabledUpdateLanguages(“en”) 
$wsusConfig.Save()

#Get WSUS Subscription and perform initial synchronization to get latest categories:
$subscription = $wsus.GetSubscription()
$subscription.StartSynchronizationForCategoryOnly()

While ($subscription.GetSynchronizationStatus() -ne ‘NotProcessing’)
    {
        Write-Host “.” -NoNewline
        Start-Sleep -Seconds 5
    }
Write-Host “Sync is done.”

##Configure the Platforms that we want WSUS to receive updates
Get-WsusProduct | where-Object {
        $_.Product.Title -in ('Windows 10')
    } | Set-WsusProduct

##Configure the Classifications
Get-WsusClassification | Where-Object {
        $_.Classification.Title -in ('Update Rollups','Security Updates','Critical Updates','Service Packs')
    } | Set-WsusClassification

#Configure Synchronizations:
$subscription.SynchronizeAutomatically=$true

#Set synchronization scheduled for midnight each night:
$subscription.SynchronizeAutomaticallyTimeOfDay= (New-TimeSpan -Hours 0)
$subscription.NumberOfSynchronizationsPerDay=1
$subscription.Save()

#Kick off a synchronization:
$subscription.StartSynchronization()