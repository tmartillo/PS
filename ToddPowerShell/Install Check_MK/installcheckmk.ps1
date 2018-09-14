#Variables
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
$computer = [Microsoft.VisualBasic.Interaction]::InputBox("Enter a computer name", "Computer", " ")

# create remote session
echo "Creating Session"
	enter-pssession -computername $computer
	
#This section will install the software 

    $destinationFolder = "\\$computer\C$\temp\"
    #$destinationFolder = "C:\temp\"
 
	#This section will copy the $sourcefile to the $destinationfolder. If the Folder does not exist it will create it.
    echo "copying file"
    echo "testing.txt" >> $destinationFolder
	echo "testing if path exists"
	if (!(Test-Path -path $destinationFolder))
    {
        echo "it did not"
		New-Item $destinationFolder -Type Directory
    }
        echo "copying the file"
        
        Copy-Item -Path "\\usssusfs0001\Software\Software\Check_MK\check_mk_agent.msi" -Destination $destinationFolder
  #  }
  
	
	Echo "Invoking the command"
	start-process -filepath "msiexec.exe" -argumentlist "/i $destinationFolder\check_mk_agent.msi /qn REBOOT=ReallySuppress /l c:\temp\pslog.log"