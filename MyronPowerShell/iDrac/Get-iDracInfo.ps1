<# 
.Synopsis 
   Display iDRAC information.


.DESCRIPTION 
   This script is designed to provide iDRAC (Integrated DellEMC Remote Access Controller
   information on DellEMC Servers running Windows Server 2016.


.REQUIREMENTS
   Remote Server Administrator Tools (RSAT) for Windows 10 or
   Active Directory module for Windows PowerShell (RSAT-AD-PowerShell), if you
   are running the script from a server. Also, ICMP must be allowed in order to test if server is up-and-running.


.NOTES 
   Created by: Fabiano Teixeira
   Modified: 8/31/2017
  
#>


#Creating new Directory and Temp Files, ignoring error if directory/file already exist
#New-Item -Type Directory -Path C:\Users\ssimgrade\Documents\Developments\Powershell\MyronPowerShell\iDrac -ErrorAction SilentlyContinue
New-Item -ItemType File -Path C:\Support\DellEMCServerList.csv -ErrorAction SilentlyContinue
New-Item -ItemType File -Path C:\Support\ServerList.csv -ErrorAction SilentlyContinue
#---New-Item -ItemType File -Path C:\Support\MyDellEMCServerList.csv -ErrorAction SilentlyContinue

#Get server information from Active Directory - Computer object must be enabled in AD and OS must be WS2016, then export information to a CSV - Excluding Cluster CNO
Get-ADComputer -Filter {(OperatingSystem -like "*Server 2003*") -and (Enabled -eq "True") -and (Description -notlike "*" -or (Description -notlike "*Cluster virtual network*"))} | Select-Object Name | Export-Csv -Path "C:\Support\ServerList.csv" -NoTypeInformation


#Import CSV to variable
$ServerList = Import-Csv -Path C:\Support\ServerList.csv



#Test Server connectivity, determine if server is a VM or Physical and determine if server is a DellEMC Server, export DellEMC server list to a CSV
ForEach ($Server in $ServerList)
{
    $Ping = Test-Connection -ComputerName $Server.name -Count 2 -Quiet
    If ($Ping -eq $True)
    {
        $ServerInfo = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Server.name -ErrorAction SilentlyContinue

        $IP = (Test-Connection -ComputerName $env:computername -count 1).IPV4Address.ipaddressTOstring 

        If ($ServerInfo.model -match "Virtual" -or $ServerInfo.model -match "VM" -and $ServerInfo.manufacturer -ne "Dell Inc.")
        {
            Write-Host "Server "$Server.name" is a VM or a Non-DellEMC Server." -ForegroundColor Yellow
        }
        Else
        {
            $ServerInfo | Select-Object Name,Manufacturer,Model | Export-Csv -Path "C:\Support\DellEMCServerList.csv" -Append -NoTypeInformation
            #$IP | Select-Object IPv4 | Export-Csv -Path 
        }
    }
}


#Import CSV to variable
$iDracList = Import-Csv -Path C:\Support\DellEMCServerList.csv -ErrorAction SilentlyContinue


#Display iDRAC Information
If ($iDracList.Name -eq $null)
{
    Write-Host "No DellEMC servers running Windows 2016 were found!"  -ForegroundColor Red
}
Else
{
    
    #Export Info to a CSV file
     Get-PcsvDevice -CimSession $iDracList.Name | Select-Object PSComputerName,Model,CurrentBIOSVersionString,IPv4Address,IPv4SubnetMask,IPv4DefaultGateway | Export-Csv "C:\Support\MyDellEMCServerList.csv" -Append -NoTypeInformation 
    #Get-PcsvDevice -TargetAddress $IP -ManagementProtocol IPMI
    
    
    #Display Info on screen
    Get-PcsvDevice -CimSession $iDracList.Name | Sort-Object -Property PSComputerName | Format-Table PSComputerName,Model,CurrentBIOSVersionString,IPv4Address,IPv4SubnetMask,IPv4DefaultGateway -ErrorAction SilentlyContinue
}


#Cleanup - Removing Temp Files
Remove-Item -Path C:\Support\ServerList.csv
Remove-Item -Path C:\Support\DellEMCServerList.csv
