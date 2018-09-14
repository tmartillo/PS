#This script is intended to produce a working Master Server list. It will include Powered On VMs and Pingable Servers from a full Active Directory Server Export. 
#The final list will be:  C:\temp\MSLFinal.csv

if(!(Test-Path -Path c:\temp )){
    New-Item -ItemType directory -Path c:\temp
}

#Remove previously created files
if (Test-Path c:\temp\MSLPingable.csv) { Remove-Item c:\temp\MSLPingable.csv }
if (Test-Path c:\temp\MSLNOPing.csv) { Remove-Item c:\temp\MSLNOPing.csv }
if (Test-Path c:\temp\MSLFinal.csv) { Remove-Item c:\temp\MSLFinal.csv }
if (Test-Path c:\temp\MSLtemp2.csv) { Remove-Item c:\temp\MSLtemp2.csv }
if (Test-Path c:\temp\MSLtemp1.csv) { Remove-Item c:\temp\MSLtemp1.csv }

#Connect to necessary vcenters
connect-viserver usssusvc001
connect-viserver ssdsbrvc0001
Connect-VIServer ssisusvc0005
Connect-VIServer usssusvc010

#----------------------------------------------------------------------------
#Get a list of VMs. Including only the name
#Adding a note to see if this pushes a new version.
#The next line saves the output to an array.  Later you will compare this to the MSL.
$VMList = get-vm  |  Where {$_.PowerState -eq 'PoweredOn'} |  Select -ExpandProperty Name
#$VMList = get-vm  |  Where {$_.PowerState -eq 'PoweredOn'} 
#$VMList 

echo "ServerName" > C:\temp\MSLPingable.csv
echo $VMList >> C:\temp\MSLPingable.csv
#foreach ($name in $VMList){
#(Get-VM $name).guest.hostname
#Add-Content c:\temp\MSLPingable.csv "$name"
#  }
#----------------------------------------------------------------------------
#Add the VMWARE MSLtemp1 to the MSLPingable.csv
$a = get-vmhost 
$a = $a | select name

echo $a >> c:\temp\MSLtemp1.csv

#Trim the domain info off
$search = [regex]::Escape(".nasa.group.atlascopco.com")    
(Get-Content c:\temp\MSLtemp1.csv) -replace $search, "" | Set-Content c:\temp\MSLtemp2.csv

#Remove the spaces
$content = Get-Content c:\temp\MSLtemp2.csv
$content | Foreach {$_.TrimEnd()} | Set-Content c:\temp\MSLtemp2.csv

#Add the content to the MSLPingable.csv file
$MSLtemp1 = Import-Csv c:\temp\MSLtemp2.csv
echo $MSLtemp1 >> c:\temp\MSLPingable.csv

#----------------------------------------------------------------------------
#Get AD List: 
#Search AD for Windows Servers
$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
$objSearcher.Filter = '(OperatingSystem=Window*Server*)'
"Name","canonicalname","distinguishedname" | Foreach-Object {$null = $objSearcher.PropertiesToLoad.Add($_) } | Where-Object {$_.lastlogondate -ge (get-date).adddays(-90)}
$ActiveADArray = $objSearcher.FindAll() | Select-Object @{n='Name';e={$_.properties['name']}},@{n='ParentOU';e={$_.properties['distinguishedname'] -replace '^[^,]+,'}},@{n='CanonicalName';e={$_.properties['canonicalname']}},@{n='DN';e={$_.properties['distinguishedname']}} 
#$ActiveADarray.name

#Ping each AD Server and only keep the ones that are active
foreach ($name in $ActiveADArray.name){
    #save the servers that DO ping to a file
  if (Test-Connection -ComputerName $name -Count 1 -ErrorAction SilentlyContinue){
    Add-Content c:\temp\MSLPingable.csv "$name"
	Write-Host "$name,up"
  }
  #save the servers that do NOT ping to a file
  else{
    Add-Content c:\temp\MSLNOPing.csv "$name"
	Write-Host "$name,down"
  }
}

$CombinedList = Import-Csv c:\temp\MSLPingable.csv
$CombinedList | sort ServerName -unique | Export-Csv c:\temp\MSLFinal.csv

echo "The final list can be found at c:\temp\MSLFinal.csv"
