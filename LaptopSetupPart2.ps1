#STEP 4: Make Domain User Admin on local machine
$username = Get-WmiObject -Class Win32_ComputerSystem | select username -ExpandProperty username
$username = $username.Trimstart("INFORELIANCE\")
$domain = $env:USERDOMAIN
$group = [ADSI]("WinNT://"+$env:computername+"/administrators,group") 
$group.add("WinNT://$username") 
$model = Get-WmiObject -Class Win32_ComputerSystem | select model -ExpandProperty model
#Get-WmiObject -Class Win32_ComputerSystem | select username

#STEP 5: ADD TO EXCEL

echo off #Log.bat file that maps the network drives for Admin
echo Mapping default drives...
net use i: /d
net use i: \\IRPM-FPS-01.inforeliance.com\InfoReliance /user:"svc.helpdesk" 
echo Drive mapping complete.

$excel_file_path = 'I:\Infrastructure\Workstation Inventory\computerNameBook.xlsm' 
## Instantiate the COM object
$Excel = New-Object -ComObject Excel.Application
$Excel.DisplayAlerts = $false
$ExcelWorkBook = $Excel.Workbooks.Open($excel_file_path)
$ExcelWorkSheet = $Excel.Sheets.item(1)
$ExcelWorkSheet.activate()
## Find the first row where the first 7 columns are empty
$Name = $username
$ComputerName = $env:Computername
$SearchString = $env:ComputerName
$Range = $ExcelWorkSheet.Range("B1").EntireColumn
$Search = $Range.find($SearchString)
$date = get-date -format("MM/dd/yyyy")
$row = $ExcelWorkSheet.UsedRange.Rows.Count + 1 

if (!($Search))
{
    $ExcelWorkSheet.Cells.Item($row,1) = $Name
    $ExcelWorkSheet.Cells.Item($row,2) = $ComputerName 
    $ExcelWorkSheet.Cells.Item($row,4) = $model
    $ExcelWorkBook.Save()
    $ExcelWorkBook.Close()
    $Excel.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel)
    Stop-Process -Name EXCEL -Force
}
else
{
    $ExcelWorkSheet.Cells.Item($Search.Row,1) = $Name #Change Name in Column A command 
    $ExcelWorkSheet.Cells.Item($Search.Row,3) = $date
    $ExcelWorkBook.Save()
    $ExcelWorkBook.Close()
    $Excel.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel)
    Stop-Process -Name EXCEL -Force
}

SchTasks /Delete /TN "LaptopP2" /F 
wusa /uninstall /kb:2693643 /quiet
Remove-Item C:\LaptopSetupPart1.ps1
Remove-Item C:\LaptopSetupPart2.ps1 
Start-Sleep -s 8
Restart-Computer