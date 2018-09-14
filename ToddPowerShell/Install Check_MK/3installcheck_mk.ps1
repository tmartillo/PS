$computers = 'aitsus20121', 'aitsus20122'
$sourcefile = "\\usssusfs0001\software\Software\Check_MK\check_mk_agent.msi"

$jobscript = {
	Param($computer)
	$destinationFolder = "\\$computer\C$\Temp"
	if (!(Test-Path -path $destinationFolder)) {
		New-Item $destinationFolder -Type Directory
	}
	Copy-Item -Path $sourcefile -Destination $destinationFolder
	Invoke-Command -ComputerName $computer -ScriptBlock { Msiexec c:\temp\check_mk_agent.msi /i  /log C:\temp\MSIInstall.log }
}

$computer | 
	ForEach-Object{
		Start-Job -ScriptBlock $jobscript -ArgumentList $_ -Credential $domaincredentail
	}
