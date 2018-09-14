



$server=Get-PSWSUSClient aca | select -expand fulldomainname
 foreach ($name in $row)
        {
            
            Remove-PSWSUSClientFromGroup -group "production" -computer $name
            
        }