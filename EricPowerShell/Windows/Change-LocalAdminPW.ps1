# From https://community.spiceworks.com/scripts/show/2978-change-local-user-password-for-remote-computers

$path = 'C:\temp\servers.txt'
$computers = Get-Content -path $path
$password = Read-Host -prompt "Enter new password for user" -assecurestring
$decodedpassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
Foreach($computer in $computers)
{
 $computer
 $user = [adsi]"WinNT://$computer/administrator,user"
 $user.SetPassword($decodedpassword)
 $user.SetInfo()
}