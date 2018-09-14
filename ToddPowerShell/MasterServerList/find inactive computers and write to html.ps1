#Find Inactive AD Servers
Get-ADComputer –filter * -prop passwordLastSet,whencreated | 
Where { $_.passwordLastSet –eq $null –or $_.passwordLastSet –lt (Get-Date).AddDays(-30) } | 
ConvertTo-HTML –PreContent 'Possibly-inactive users' –Prop Name,PasswordLastSet,whenCreated | 
Out-File C:\temp\InactiveComputers.html