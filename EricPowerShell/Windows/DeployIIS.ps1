#####
## Run the following code to install DFS
##
## If source files are needed use -Source and point to the location of the winxs
## Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools -Source \\server2\winsxs
#####

Install-WindowsFeature -Name "Web-Server" -IncludeAllSubFeature -IncludeManagementTools -Source "\\usssusfs0001\Software\Software\Microsoft\Server2012Sources\sxs" -Restart
