# From https://ict-freak.nl/2009/10/05/powercli-enabledisable-the-vm-hot-add-features/
Function Disable-vCpuHotAdd($vm){
    $vmview = Get-vm $vm | Get-View 
    $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec

    $extra = New-Object VMware.Vim.optionvalue
    $extra.Key="vcpu.hotadd"
    $extra.Value="false"
    $vmConfigSpec.extraconfig += $extra

    $vmview.ReconfigVM($vmConfigSpec)
}