$SOS=([System.Environment]::OSVersion.Version.Major –ge “6”)

# Check OS Version
$CheckOS = {
If ($SOS -eq "True"){
Write-output "Windows 2008 or greater"
} Else {
Write-output "Widnows 2003 or lower"}
}
