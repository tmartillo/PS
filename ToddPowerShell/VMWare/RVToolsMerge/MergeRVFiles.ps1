$file1 = 'C:\Book1.xlsx'                            # source's fullpath
$file2 = 'C:\Book2.xlsx'                       # destination's fullpath
$xl = new-object -c excel.application
$xl.displayAlerts = $false                      # don't prompt the user
$wb1 = $xl.workbooks.open($file1, $null, $true) # open source, readonly
$wb2 = $xl.workbooks.open($file2)                         # open target
$sh1_wb2 = $wb2.sheets.item(1)    # first sheet in destination workbook
$sheetToCopy = $wb1.sheets.item('sheetToCopy')   # source sheet to copy
$sheetToCopy.copy($sh1_wb2) # copy source sheet to destination workbook
$wb1.close($false)                   # close source workbook w/o saving
$wb2.close($true)                 # close and save destination workbook
$xl.quit()
spps -n excel