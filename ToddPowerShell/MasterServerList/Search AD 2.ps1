import-module ActiveDirectory

#create .csv file with a list of all of our servers
get-adcomputer -filter * -SearchBase 'dc=nasa, dc=group, dc=atlascopco, dc=com' | select dnshostname | export-csv "c:\scripts\servernames.csv"

#create an array from the csv file
$servernames = @(import-csv "C:\scripts\servernames.csv")

#create array used to capture hostname, mac and ip address
$outarray = @()

#loop through each element in the array to retrieve Server name, mac and ip Address
foreach ( $servername in $servernames )
{

#get mac and ip address
$colItems = Get-WmiObject -Class "Win32_NetworkAdapterConfiguration" -ComputerName $servername.dnshostname -Filter "IpEnabled = TRUE"

#populate array with results
    foreach ($item in $colitems)
    {
        $outarray += New-Object PsObject -property @{
        'Server' = $item.DNSHostName
        'MAC' = $item.MACAddress
        'IP' = [string]$item.IPAddress
        }
    } 
}

#export to .csv file
$outarray | export-csv c:\scripts\final.csv