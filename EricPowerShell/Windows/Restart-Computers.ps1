## Script to restart cpmputers

$computers = Get-content C:'\temp\file.txt'

ForEach ($computers in $computers)

    {Restart-Computer -ComputerName $name -Verbose}
