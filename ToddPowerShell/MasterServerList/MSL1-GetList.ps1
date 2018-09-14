#Connect to necessary vcenters
connect-viserver usssusvc001
connect-viserver ssdsbrvc0001
Connect-VIServer 10.128.30.151
# Connect-VIServer usssusvc010

#Get a list of VMs. Including only the name
#Adding a note to see if this pushes a new version.
#The next line saves the output to an array.  Later you will compare this to the MSL.
$VMList = get-vm  |  Where {$_.PowerState -eq 'PoweredOn'} |  Select -ExpandProperty Name
#$VMList = get-vm  |  Where {$_.PowerState -eq 'PoweredOn'} 
$VMList 

foreach ($name in $VMList){
  if (Test-Connection -ComputerName $name -Count 3 -ErrorAction SilentlyContinue){
    Add-Content c:\temp\vmupservers.csv "$name,up"
	Write-Host "$name,up"
  }
  else{
    Add-Content c:\temp\vmdownservers.csv "$name,down"
	Write-Host "$name,down"
  }
}
