$servers = Get-Content -path "C:\temp\servers.txt"
$target = "OU=Servers,OU=Santiago,OU=CHL,OU=MR,DC=nasa,DC=group,DC=atlascopco,DC=com"
$DC = "ssiscldc0001"

ForEach ($host in $servers)

    {Move-ADObject -Server $DC -TargetPath $target -Confirm:$false -Verbose}