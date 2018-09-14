$targets = 'usssusas031'
ForEach-object {
   $vm = $targets
   Get-VM $vm | Get-Snapshot | Remove-Snapshot -confirm:$false
   $vmView = Get-vm $vm | get-view
   $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
   $vmConfigSpec.changeTrackingEnabled = $true
   $vmView.reconfigVM($vmConfigSpec)
   New-Snapshot -VM (Get-VM $vm ) -Name "CBTSnap"
   Get-VM $vm | Get-Snapshot -Name "CBTSnap" | Remove-Snapshot -confirm:$false
}

Get-VM | Get-View | Sort Name | Select Name, @{N="ChangeTrackingStatus";E={$_.Config.ChangeTrackingEnabled}}