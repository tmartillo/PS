<# 
.Synopsis 
   Display iDRAC information.


.DESCRIPTION 
   This script is designed to provide iDRAC (Integrated DellEMC Remote Access Controller
   information on DellEMC Servers running Windows Server.


.REQUIREMENTS
   Remote Server Administrator Tools (RSAT) for Windows 10 or
   Active Directory module for Windows PowerShell (RSAT-AD-PowerShell), if you
   are running the script from a server. Also, ICMP must be allowed in order to test if server is up-and-running.


.NOTES 
   Created by: Myron Grade
  
#>


$User = "ssimgrade"

$DellEMCs = "C:\Users\" + $User + "\Desktop\DellEMCServerList.csv"
$EMC = "C:\Users\" + $User + "\Desktop\ServerList.csv"


Write-Host "Acceptable input format: 2003, Server 2012, Server 2008, 2012"
$operatingSystem = Read-Host -Prompt "Enter the name of the Operating System to extrapolate"
$promptResponse = "*$operatingSystem*"
#Write-Output "Querying Active Directory for Servers"
Write-Host "Querying Active Directory for Servers"


<#
$ServerList = Get-ADComputer -Filter {
    (OperatingSystem -like "*Server 2013*") `
    -and (Enabled -eq "True") `
    -and (Description -notlike "*" `
    -or (Description -notlike "*Cluster virtual network*"))} `
    | Select-Object Name
    #>

$ServerList = Get-ADComputer -Filter {(OperatingSystem -like $promptResponse) -and (Enabled -eq "True") -and (Description -notlike "*" -or (Description -notlike "*Cluster virtual network*"))} | Select-Object Name
#$ServerList = Get-ADComputer -Filter {(OperatingSystem -like "*Server 2003*") -and (Enabled -eq "True") -and (Description -notlike "*" -or (Description -notlike "*Cluster virtual network*"))} | Select-Object Name

ForEach ($Server in $ServerList) {

    # Delimit ServerInfo attempt
    Write-Host ""
    Write-Host "---------------"

    Write-Host "Attempting to ping server:" $Server.name
    $Ping = Test-Connection -ComputerName $Server.name -Count 2 -Quiet

    If ($Ping -eq "True") {

        Write-Host "Successfully able to ping server:" $Server.name
        
        try {

            Write-Host "Attempting to get Win32_ComputerSystem for server:" $Server.name
            $ServerInfo = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Server.name -ErrorAction SilentlyContinue

            #Attempt to get the system information of the server
            If ($ServerInfo.manufacturer -ne "Dell Inc." -and ( $ServerInfo.model -match "Virtual" -or $ServerInfo -match "VM" )) {
                
                Write-Host "Server "$Server.name" is a VM or a Non-DellEMC Server." -ForegroundColor Yellow

                Write-Host "YERP" 

            } Else {

                Write-Host "Server:" $ServerInfo.name ", Manufacturer:" $ServerInfo.manufacturer ", Model:" $ServerInfo.model
                $ServerMetadata = Select-Object -InputObject $ServerInfo Name,Manufacturer,Model

                

            }


        } catch [System.UnauthorizedAccessException] {

            Write-Host "Unable to get Win32_ComputerSystem for server '"$Server.name"' due to unauthorized access."

        } catch {
            
            Write-Host "Unable to get Win32_ComputerSystem for server '"$Server.name"'"

        }

    } Else {
        
        Write-Host "Unable to ping server:" $Server.name

    }
}


# TODO:  Determine a way to gain access to iDRAC information in order to grab IP addresses

<#
#Attempt to get the ip address from the Dell EMC servers
If($ServerMetadata.Name -eq $Null) {

    Write-Host "No DellEMC servers running on server: '"$ServerMetadata.name"'"

} Else {

    Get-NetIPAddress -CimSession $ServerMetadata.name -AddressFamily IPv4

}
#>