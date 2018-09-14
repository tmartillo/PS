#Search AD for Windows Servers
$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
$objSearcher.Filter = '(OperatingSystem=Window*Server*)'
"Name","canonicalname","distinguishedname" | Foreach-Object {$null = $objSearcher.PropertiesToLoad.Add($_) } | Where-Object {$_.lastlogondate -ge (get-date).adddays(-90)}
$ActiveADArray = $objSearcher.FindAll() | Select-Object @{n='Name';e={$_.properties['name']}},@{n='ParentOU';e={$_.properties['distinguishedname'] -replace '^[^,]+,'}},@{n='CanonicalName';e={$_.properties['canonicalname']}},@{n='DN';e={$_.properties['distinguishedname']}} 
#$ActiveADarray.name

# Test for connectivity of each item in the array
foreach ($name in $ActiveADArray.name){
  if (Test-Connection -ComputerName $name -Count 3 -ErrorAction SilentlyContinue){
    Add-Content c:\temp\upservers.csv "$name,up"
	Write-Host "$name,up"
  }
  else{
    Add-Content c:\temp\downservers.csv "$name,down"
	Write-Host "$name,down"
  }
}

#| Where-Object {$_.lastlogondate -ge (get-date).adddays(-90)}