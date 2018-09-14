
#Pre-Requisite of downloading psexec sysinternals tool
#Copies KB923845 and Install bits 2.5 on win2k3
#Must be in directory where psexec is located
$Computers = Get-Content 'C:\Temp\bitssccmtargets.txt'
$file = "\\usssusfs0001\software\Software\Microsoft\WindowsServer2003-KB923845-x86-ENU.exe"
$root = "\\$computer\c$\"
$path = "\\$computer\c$\temp"
$folder = 'temp'
$KB = "C:\temp\WindowsServer2003-KB923845-x86-ENU.exe"
foreach($Computer in $Computers ){
    if((test-path -path "\\$computer\c$\temp") -eq $false) 
    {
        Copy-Item -Path $file -Destination (New-Item -path "\\$computer\c$\" -name "temp" -Type Directory) -Force -Verbose
    }
    else
    {
        Copy-Item -Path $file -Destination 'temp' -Force -Verbose
    }
if((Test-Path $KB) -eq $true)
    {   
        .\psexec.exe \\$computer -e -high /accepteula $KB /quiet
    }
}


#Pre-Requisite of downloading psexec sysinternals tool
#Must be in directory where psexec is located
#Copies KB923845 and Install bits 2.5 on win2k3 x64
$Computers = Get-Content 'C:\Temp\bitssccmtargets.txt'
$file = "\\usssusfs0001\software\Software\Microsoft\WindowsServer2003.WindowsXP-KB923845-x64-ENU.exe"
$root = "\\$computers\c$\"
$path = "\\$computers\c$\temp"
$folder = 'temp'
$KB = "C:\temp\WindowsServer2003.WindowsXP-KB923845-x64-ENU.exe"
foreach($Computer in $Computers ){
    if((test-path $path) -eq $false) 
    {
        Copy-Item -Path $file -Destination (New-Item $root -name $folder -Type Directory) -Force 
    }
    else
    {
        Copy-Item -Path $file -Destination $path -Force
    }
    if((Test-Path $path) -eq $true)
    {   
        .\psexec.exe \\$computer -d -e -high /accepteula $KB /quiet
    }
}

#Pre-Requisite of downloading psexec sysinternals tool
#Copies KB923845 and Install bits 2.5 on win2k3
#Must be in directory where psexec is located
$Computers = Get-Content 'C:\Temp\bitssccmtargets.txt'
$file = "\\usssusfs0001\software\Software\Microsoft\WindowsServer2003.WindowsXP-KB923845-x64-ENU.exe"
foreach($Computer in $Computers ){
$root = "\\$computer\c$\"
$path = "\\$computer\c$\temp"
$folder = 'temp'
    if((test-path $path) -eq $false) 
    {
        Copy-Item -Path $file -Destination (New-Item $root -name $folder -Type Directory) -Force -Verbose
    }
    else
    {
        Copy-Item -Path $file -Destination $path -Force -Verbose
    }
}


$Computers = Get-Content 'C:\Temp\bitssccmtargets.txt'
$file = "\\usssusfs0001\software\Software\Microsoft\WindowsServer2003-KB923845-x86-ENU.exe"
$KB = "C:\temp\WindowsServer2003-KB923845-x86-ENU.exe"
foreach($Computer in $Computers )
{   
        .\psexec.exe \\$computer -e -d -high /accepteula $KB /quiet
    }


$Computers = Get-Content 'C:\Temp\bitssccmtargets.txt'
$file = "\\usssusfs0001\software\Software\Microsoft\WindowsServer2003.WindowsXP-KB923845-x64-ENU.exe"
$KB = "C:\temp\WindowsServer2003.WindowsXP-KB923845-x64-ENU.exe"
foreach($Computer in $Computers )
{   
        .\psexec.exe \\$computer -e -d -high /accepteula $KB /quiet
    }