
$report =@() 
Get-VM | Get-View | %{ 
 $VMname = $_.Name 
 $_.guest.net | where {$_.MacAddress -eq "00:50:56:b9:72:b3"} | %{
        $row = "" | Select VM, MAC
        $row.VM = $VMname 
        $row.MAC = $_.MacAddress 
        $report += $row 
  } 
  } 
$report