# NOTE: You must know the local administrator password in order to login
$server = 'SERVERNAME'
$cred = 'NASA\YOUR_ADM'

Remove-Computer -ComputerName $server -UnjoinDomainCredential $cred -WorkgroupName "WORKGROUP" -Restart -Force -Verbose
Get-ADComputer -filter 'name -eq $server' | Remove-ADComputer  -Verbose -confirm:$false