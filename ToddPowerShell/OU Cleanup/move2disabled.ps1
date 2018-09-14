#Move computers to the Disabled Computers OU

$Disabled = GC "disabled.txt"
ForEach($computer in $Disabled) 
{
# echo $computer    
get-adcomputer $computer | move-adobject -targetpath "OU=Disabled Computers,DC=nasa,DC=group,DC=atlascopco,DC=com"
}