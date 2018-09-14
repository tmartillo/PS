$Catalog = GC "guests.txt"
ForEach($Machine in $Catalog) 
{ 
    Update-Tools "$Machine" 
    Write-Host $Machine 
}