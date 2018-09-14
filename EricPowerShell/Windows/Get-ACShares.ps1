####
## Gather shares from list of shares from list of servers
## Code from serverfault.com
## https://serverfault.com/questions/623710/can-you-use-a-powershell-script-to-find-all-shares-on-servers
##
####

$Servers = "C:\Temp\ShareList.txt"
$Export = "C:\Temp\SharesOnServers.csv"
$ComputerNames = Get-Content $Servers

$AllComputerShares = @()

foreach($Computer in $ComputerNames)
{
    try{
        $Shares = Get-WmiObject -ComputerName $Computer -Class Win32_Share -ErrorAction Stop
        $AllComputerShares += $Shares
    }
    catch{
        Write-Error "Failed to connect retrieve Shares from $Computer"
    }
}

# Select the computername and the name, path and comment of the share and Export
$AllComputerShares | Select-Object -Property PSComputerName,Name,Path,Description | Export-Csv -Path $Export -NoTypeInformation