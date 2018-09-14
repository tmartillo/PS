#To create a EndPoint Config file
New-PSSessionConfigurationFile -Path "C:\Scripts\PSRoleCapabilityFiles\NewServerName.pssc" -ModulesToImport "ActiveDirectory" -VisibleCmdlets "Get-ADComputer"

#To register the config as an EndPoint
Register-PSSessionConfiguration -Name "FindNewServerName" -Path "C:\Scripts\PSRoleCapabilityFiles\FindNewServerName.pssc" –ShowSecurityDescriptorUI -RunAsCredential nasa\ssiet_adm

#To Unregister an EndPoint
Unregister-PSSessionConfiguration -Name FindNewServerName