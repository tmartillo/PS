#This example useses the VisitourSrv service. 
$ServiceName = 'VisiTourSrv'
$arrService = Get-Service -Name $ServiceName
# echo $arrservice
if ($arrService.Status -ne 'Running'){
Write-Output "2 VisitourService status=crit Visitour Service is Not Running"
$ServiceStarted = $false
}
Else{Write-Output "0 VisitourService status=OK Visitour Service is OK"
$ServiceStarted = $true
}

#This Section attempts to restart the service if it is not running. 
 
while ($ServiceStarted -ne $true){
    Start-Service $ServiceName
    write-host $arrService.status
    write-host 'Service started'
    $arrService = Get-Service -Name $ServiceName 
    if ($arrService.Status -eq 'Running'){
    $ServiceStarted = $true}
    }