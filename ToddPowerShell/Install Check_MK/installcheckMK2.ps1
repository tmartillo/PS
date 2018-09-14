$computername = 'aitsusas0001'
$sourcefile = "\\usssusfs0001\software\Software\Check_MK\check_mk_agent.msi"

foreach ($computer in $computername) {
	echo "checking $computername"
    $destinationFolder = "\\$computer\C$\Temp"
	
	if (!(Test-Path -path $destinationFolder )) {
		#New-Item $destinationFolder -Type Directory -Credential $domaincredentials
        New-Item $destinationFolder -Type Directory 
	}
#	Copy-Item -Path $sourcefile -Destination $destinationFolder -Credential $domaincredentials
	Copy-Item -Path $sourcefile -Destination $destinationFolder 


#	Invoke-Command -ComputerName $computer -Credential $domaincredentials -ScriptBlock { Msiexec /i \\usssusfs0001\software\Software\Check_MK\check_mk_agent.msi /log C:\MSIInstall.log }}
	Invoke-Command -ComputerName $computer -ScriptBlock { Msiexec /i \\$destinationFolder\check_mk_agent.msi }}
