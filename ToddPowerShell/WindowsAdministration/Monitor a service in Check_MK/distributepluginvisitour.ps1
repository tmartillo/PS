$sourcefile = ".\visitour.ps1"
$computername = Read-Host -Prompt "Enter name of Server"

	echo "checking $computername"
    $destinationFolder = "\\$computername\C$\\Program Files (x86)\check_mk\local"
	
	if (!(Test-Path -path $destinationFolder )) {
		#New-Item $destinationFolder -Type Directory -Credential $domaincredentials
        New-Item $destinationFolder -Type Directory 
	}
#	Copy-Item -Path $sourcefile -Destination $destinationFolder -Credential $domaincredentials
	Copy-Item -Path $sourcefile -Destination $destinationFolder 
