# Written by Luke Huckaba
# http://thephuck.com
# @thephuck
#
# v0.1 - 20140429
#
 
param([string]$vDC, [string]$srcvcenter, [string]$destvcenter)
if((-not($vDC)) -and (-not($vcenter))){Throw "You must supply a vDatacenter and vCenter: -vDC ###### -vcenter vcentername"}
 
$ErrorActionPreference = "SilentlyContinue"
 
if($global:DefaultVIServer){Disconnect-VIServer -Server * -Force -Confirm:$false}
 
connect-viserver $srcvcenter
 
$vdatacenter = get-datacenter $vDC
 
$clusters = get-cluster -lo $vdatacenter
 
$VMhosts = get-vmhost -lo $vdatacenter
 
foreach($VMhost in $VMhosts){
     Get-VMHost $VMhost | Set-VMHost -State Disconnected | Remove-VMHost -Confirm:$false
}
 
Disconnect-VIServer -Server * -Force -Confirm:$false
connect-viserver $destvCenter
New-Datacenter $vDC -lo Datacenters
 
if($clusters){
    foreach($cluster in $clusters){
        New-Cluster -HARestartPriority $cluster.HARestartPriority -HAIsolationResponse $cluster.HAIsolationResponse -VMSwapfilePolicy $cluster.VMSwapfilePolicy -Name $cluster.Name -Location $vDatacenter.Name -HAEnabled -HAAdmissionControlEnabled -HAFailoverLevel $cluster.HAFailoverLevel -DrsEnabled -DrsMode $cluster.DrsMode -DrsAutomationLevel $cluster.DrsAutomationLevel -EVCMode $cluster.EVCMode
    }
}
 
Foreach($VMhost in $VMhosts){
 
    $esx_host_creds = $host.ui.PromptForCredential("ESXi Credentials Required", "Please enter credentials to log into the ESXi host.", "", "")
    if($clusters){
        Add-VMHost -Name $VMhost.Name -Location $VMhost.Parent -Credential $esx_host_creds -Force:$true
    }
    else{
        Add-VMHost -Name $VMhost.Name -Location $vdatacenter -Credential $esx_host_creds -Force:$true
    }
}