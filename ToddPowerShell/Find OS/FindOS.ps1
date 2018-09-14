# Get Operating System Info
# edit the server.txt file found in this folder with your list of servers to investigate. 
$Catalog = GC "server.txt"
ForEach($Machine in $Catalog) 
{$QueryString = Gwmi Win32_OperatingSystem -Comp $Machine 
$QueryString = $QueryString.Caption 
Write-Host $Machine ":" $QueryString}
