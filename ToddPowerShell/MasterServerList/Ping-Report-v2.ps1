#Requires -Version 2


<#
Script to ping and report on computers.
Data reported: ComputerName, IPAddress, MACAddress, DateBuilt, OSVersion, Model, Manufacturer, OSCaption, VirtualMachine, OSArchitecture, and LastBootTime
For more information and use examples see https://superwidgets.wordpress.com/2017/01/04/powershell-script-to-report-on-computer-inventory/
Sam Boutros - 31 October 2014 v1.0 - 4 January 2017 v2.0
#>


[CmdletBinding(ConfirmImpact='Low')] 
Param([Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
    [String[]]$ComputerName = $env:COMPUTERNAME)

$PCData = @()
foreach ($PC in $ComputerName) {
    try {
        Test-Connection -ComputerName $PC -Count 2 -ErrorAction Stop | Out-Null
        foreach ($IPAddress in ((Get-WmiObject -ComputerName $PC -Class "Win32_NetworkAdapterConfiguration" | 
            Where { $_.IpEnabled -Match "True" }).IPAddress | where { $_ -match "\." })) {
            $OS    = Get-WmiObject -ComputerName $PC -Class Win32_OperatingSystem
            $Mfg   = Get-WmiObject -ComputerName $PC -Class Win32_ComputerSystem
            $Props = @{
                ComputerName   = $PC
                Status         = 'Online'
                IPAddress      = $IPAddress
                MACAddress     = (Get-WmiObject -ComputerName $PC -Class "Win32_NetworkAdapterConfiguration" | 
                    Where { $_.IPAddress -eq $IPAddress }).MACAddress
                DateBuilt      = ([WMI]'').ConvertToDateTime($OS.InstallDate)
                OSVersion      = $OS.Version
                OSCaption      = $OS.Caption
                OSArchitecture = $OS.OSArchitecture
                Model          = $Mfg.model
                Manufacturer   = $Mfg.Manufacturer
                VirtualMachine = $(if ($Mfg.Manufacturer -match 'vmware' -or $Mfg.Manufacturer -match 'microsoft') { $true } else { $false })
                LastBootTime   = ([WMI]'').ConvertToDateTime($OS.LastBootUpTime)
            }
            $PCData += New-Object -TypeName PSObject -Property $Props
        }
    } catch { # either ping failed or access denied 
        try {
            Test-Connection -ComputerName $PC -Count 2 -ErrorAction Stop | Out-Null
            $Props = @{
                ComputerName   = $PC
                Status         = $(if ($Error[0].Exception -match 'Access is denied') { 'Access is denied' } else { $Error[0].Exception })
                IPAddress      = ''
                MACAddress     = ''
                DateBuilt      = ''
                OSVersion      = ''
                OSCaption      = ''
                OSArchitecture = ''
                Model          = ''
                Manufacturer   = ''
                VirtualMachine = ''
                LastBootTime   = ''
            }
            $PCData += New-Object -TypeName PSObject -Property $Props            
        } catch {
            $Props = @{
                ComputerName   = $PC
                Status         = 'No response to ping'
                IPAddress      = ''
                MACAddress     = ''
                DateBuilt      = ''
                OSVersion      = ''
                OSCaption      = ''
                OSArchitecture = ''
                Model          = ''
                Manufacturer   = ''
                VirtualMachine = ''
                LastBootTime   = ''
            }
            $PCData += New-Object -TypeName PSObject -Property $Props              
        }
    }
}
$PCData