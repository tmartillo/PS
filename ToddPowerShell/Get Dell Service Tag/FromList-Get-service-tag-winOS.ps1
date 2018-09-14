
$servers = get-content -path '.\list.txt'

#$users = Import-Csv .\list.txt
foreach ($server in $servers) {
    write-output $server
    get-wmiobject -computername $server -class win32_bios
    (Get-WmiObject -Class:Win32_ComputerSystem).Model
}


