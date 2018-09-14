$Server = get-content -path 'C:\temp\GPUpdate.txt'

foreach ($item in $Server)
        Invoke-GPUpdate -Computer $item -force -Target:Computer