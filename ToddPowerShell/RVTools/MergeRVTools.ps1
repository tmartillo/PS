$file1 = 'C:\temp\vc-vc0005.xlsx' # source's fullpath
$file2 = 'C:\temp\vc-vc0001.xlsx' # source's fullpath
$file3 = 'C:\temp\vc-vc010.xlsx' # source's fullpath
$file4 = 'C:\temp\combinedlist.xlsx' # destination's fullpath
$xl = new-object -c excel.application
$xl.displayAlerts = $false         # don't prompt the user
$wb1 = $xl.workbooks.open($file1, $null, $true) # open source, readonly
$wb2 = $xl.workbooks.open($file2, $null, $true) # open source, readonly
$wb3 = $xl.workbooks.open($file3, $null, $true) # open source, readonly
$wb4 = $xl.workbooks.open($file4) # open target
$sh1_wb4 = $wb4.sheets.item(1) # first sheet in destination workbook
$sheetToCopy = $wb1.sheets.item('vInfo')  # source sheet to copy
$sheetToCopy.copy($sh1_wb4) # copy source sheet to destination workbook
$sheetToCopy = $wb2.sheets.item('vInfo')  # source sheet to copy
$sheetToCopy.copy($sh1_wb4) # copy source sheet to destination workbook
$sheetToCopy = $wb3.sheets.item('vInfo')  # source sheet to copy
$sheetToCopy.copy($sh1_wb4) # copy source sheet to destination workbook
$wb1.close($false) # close source workbook w/o saving
$wb2.close($false) # close source workbook w/o saving
$wb3.close($false) # close source workbook w/o saving
$wb4.close($true) # close and save destination workbook
$xl.quit()
spps -n excel # Kill Excel Process