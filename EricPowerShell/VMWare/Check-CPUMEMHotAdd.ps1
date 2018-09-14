Get-VM | Get-View | Sort-Object name | Select Name, `
@{N="CpuHotAddEnabled";E={$_.Config.CpuHotAddEnabled}}, `
@{N="CpuHotRemoveEnabled";E={$_.Config.CpuHotRemoveEnabled}}, `
@{N="MemoryHotAddEnabled";E={$_.Config.MemoryHotAddEnabled}}


(Get-VM -Name ssisusdom031 | Get-View).Config.MemoryHotAddEnabled


$VM = Get-VM ssisusdom031
$spec = New-Object VMware.Vim.VirtualMachineConfigSpec
$spec.memoryHotAddEnabled = $true
#$spec.cpuHotAddEnabled = $true
$VM.ExtensionData.ReconfigVM_Task($spec)
