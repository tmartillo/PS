#####
## Run the following code to install DFS
#####

Install-WindowsFeature -name FS-FileServer,FS-DFS-Namespace,FS-DFS-Replication -IncludeManagementTools
