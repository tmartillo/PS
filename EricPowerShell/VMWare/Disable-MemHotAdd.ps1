# from https://ict-freak.nl/2009/10/05/powercli-enabledisable-the-vm-hot-add-features/
Function Disable-MemHotAdd($vm){
    $vmview = Get-VM $vm | Get-View 
    $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec

    $extra = New-Object VMware.Vim.optionvalue
    $extra.Key="mem.hotadd"
    $extra.Value="false"
    $vmConfigSpec.extraconfig += $extra

    $vmview.ReconfigVM($vmConfigSpec)
}