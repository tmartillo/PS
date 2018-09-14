$logs = Get-EventLog -list | ForEach {$_.Log}
$logs | ForEach {Clear-EventLog -Log $_}