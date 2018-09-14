<# The purpose of this script is to emulate the Command Prompt version of "SET" Command. 
To run, simply run this from the context of the server you wish to get the SET info on.
Example:
get-set
Name                           Value                                                                                                                                                                                                 
----                           -----                                                                                                                                                                                                 
ALLUSERSPROFILE                C:\ProgramData                                                                                                                                                                                        
APPDATA                        C:\Users\USER001\AppData\Roaming                                                                                                                                                                     
CommonProgramFiles             C:\Program Files\Common Files                                                                                                                                                                         
CommonProgramFiles(x86)        C:\Program Files (x86)\Common Files                                                                                                                                                                   
CommonProgramW6432             C:\Program Files\Common Files                                                                                                                                                                         
COMPUTERNAME                   COMPUTER001                                                                                                                                                                                         
ComSpec                        C:\Windows\system32\cmd.exe                                                                                                                                                                           
FPS_BROWSER_APP_PROFILE_STRING Internet Explorer                                                                                                                                                                                     
FPS_BROWSER_USER_PROFILE_ST... Default                                                                                                                                                                                               
HOMEDRIVE                      H:                                                                                                                                                                                                    
HOMEPATH                       \                                                                                                                                                                                                     
HOMESHARE                      \\FILESERVER1\USERS\USER001                                                                                                                                                                         
LOCALAPPDATA                   C:\Users\USER001\AppData\Local                                                                                                                                                                       
LOGONSERVER                    \\DOMAINCONTROLLER01                                                                                                                                                                                        
NUMBER_OF_PROCESSORS           4                                                                                                                                                                                                     
OS                             Windows_NT                                                                                                                                                                                            
Path                           C:\ProgramData\Oracle\Java\javapath;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Notes;C:\NotesSQL;C:\Program Files (x86)\Sennheiser\Soft...
PATHEXT                        .COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC;.CPL                                                                                                                                            
PROCESSOR_ARCHITECTURE         AMD64                                                                                                                                                                                                 
PROCESSOR_IDENTIFIER           Intel64 Family 6 Model 142 Stepping 9, GenuineIntel                                                                                                                                                   
PROCESSOR_LEVEL                6                                                                                                                                                                                                     
PROCESSOR_REVISION             8e09                                                                                                                                                                                                  
ProgramData                    C:\ProgramData                                                                                                                                                                                        
ProgramFiles                   C:\Program Files                                                                                                                                                                                      
ProgramFiles(x86)              C:\Program Files (x86)                                                                                                                                                                                
ProgramW6432                   C:\Program Files                                                                                                                                                                                      
PSModulePath                   C:\Users\USER001\Documents\WindowsPowerShell\Modules;C:\Program Files\WindowsPowerShell\Modules;C:\Windows\system32\WindowsPowerShell\v1.0\Modules                                                   
PUBLIC                         C:\Users\Public                                                                                                                                                                                       
SystemDrive                    C:                                                                                                                                                                                                    
SystemRoot                     C:\Windows                                                                                                                                                                                            
TEMP                           C:\Users\USER001\AppData\Local\Temp                                                                                                                                                                  
TMP                            C:\Users\USER001\AppData\Local\Temp                                                                                                                                                                  
USERDNSDOMAIN                  NASA.GROUP.ATLASCOPCO.COM                                                                                                                                                                             
USERDOMAIN                     NASA                                                                                                                                                                                                  
USERDOMAIN_ROAMINGPROFILE      NASA                                                                                                                                                                                                  
USERNAME                       USER001                                                                                                                                                                                              
USERPROFILE                    C:\Users\USER001                                                                                                                                                                                     
windir                         C:\Windows  
/#>

If (Test-Path ALIAS:set) { Remove-Item ALIAS:set }

 

Function Set {

  If (-Not $ARGS) {

    Get-ChildItem ENV: | Sort-Object Name

    Return

  }

  $myLine = $MYINVOCATION.Line

  $myName = $MYINVOCATION.InvocationName

  $myArgs = $myLine.Substring($myLine.IndexOf($myName) + $myName.Length + 1)

  $equalPos = $myArgs.IndexOf("=")

  # If the "=" character isn’t found, output the variables.

  If ($equalPos -eq -1) {

    $result = Get-ChildItem ENV: | Where-Object { $_.Name -like "$myArgs" } |

      Sort-Object Name

    If ($result) { $result } Else { Throw "Environment variable not found" }

  }

  # If the "=" character is found before the end of the string, set the variable.


  ElseIf ($equalPos -lt $myArgs.Length - 1) {

    $varName = $myArgs.Substring(0, $equalPos)

    $varData = $myArgs.Substring($equalPos + 1)

    Set-Item ENV:$varName $varData

  }

  # If the "=" character is found at the end of the string, remove the variable.

  Else {

    $varName = $myArgs.Substring(0, $equalPos)

    If (Test-Path ENV:$varName) { Remove-Item ENV:$varName }

  }

}