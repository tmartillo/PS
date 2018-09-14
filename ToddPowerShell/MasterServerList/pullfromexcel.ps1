#Read from spreadsheet
$ExcelWB = new-object -comobject excel.application
$ExcelWB.Visible = $True  
$Workbook = $ExcelWB.Workbooks.Open("C:\Users\ssithamm\Downloads\Master Server List Nov 2016.xlsx") 
$Worksheet = $Workbook.Worksheets.Item(8) 
$startRow = 5

Do { 
   $ColValues = @()
$count = $Worksheet.Cells.Item(1000, 1).End(-4162)
for($startRow=2;$startRow -le $count.row;$startRow++)
{
	$ColValues += $Worksheet.Cells.Item($startRow, 1).Value()
}
    
    }
    While ($Worksheet.Cells.Item($startRow,1).Value() -ne $null) 
   
   Write-Host $ColValues
   
    
	$ExcelWB.Quit() 

