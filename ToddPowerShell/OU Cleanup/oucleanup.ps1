#get-adcomputer Name

$Catalog = GC "servers.txt"
ForEach($Machine in $Catalog) 
{
    #$QueryString = Gwmi Win32_OperatingSystem -Comp $Machine 
#$QueryString = $QueryString.Caption 
get-adcomputer $Machine >> list.txt
#Write-Host $Machine ":" $QueryString
}