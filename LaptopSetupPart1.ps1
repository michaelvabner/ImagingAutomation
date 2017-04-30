#STEP ONE: ADD COMPUTER TO DOMAIN

$NewName = gwmi win32_bios | fl SerialNumber
$NewName = $NewName | Out-String
$NewName = $NewName.remove(0,19)
$NewName = "IRPW-" + $NewName
$NewName = $NewName.Trim()

$username = "svc.helpdesk"
$password = #
$secstr = New-Object -TypeName System.Security.SecureString
$password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr
 
try
{
Remove-ADComputer -Identity $NewName -Credential $cred -Server inforeliance.com 
}
catch
{
}
Add-Computer -DomainName Inforeliance.com -Credential $cred -NewName $NewName -Force
SCHTASKS /Delete /TN "DomainConnect" /f

#STEP 2: Encryption 

echo off #Log.bat file that maps the network drives for Admin
echo Mapping default drives...
net use q: /d
net use q: \\IRPM-FPS-01.inforeliance.com\SoftwareISO /user:"svc.helpdesk" "8QhmTjhz84"
echo Drive mapping complete. 

manage-bde -on C: -recoverypassword > Q:\VabnerEncryption\$NewName.txt #Creates recovery key in Network
#Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoAdminLogon -Value 1 #Creates auto login on admin account. Info to be changed as needed
#Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultUserName -Value "$env:computername\inforeliance" 
#Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultPassword -Value "P@ssword123"
#$Action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument 'D:\LaptopSetupPart2.ps1' #Defines variable "action", next "task"
#$Trigger =  New-ScheduledTaskTrigger -AtLogOn
#Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "LaptopP2" -Description "Prepares for next user login" -RunLevel Highest -User "$NewName\inforeliance" -Password "P@ssword123" #Creates task in task scheduler to run new variables on start up as an Admin

Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoAdminLogon -Value 0 #Reset Task Scheduler 
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultUserName -Value ""
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultPassword -Value ""
Enable-ScheduledTask -TaskName "LaptopP2"
#$Action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument 'C:\LaptopSetupPart2.ps1'
#$Trigger =  New-ScheduledTaskTrigger -AtLogOn
#Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "LaptopP2" -Description "Makes Admin and Updates info" -RunLevel Highest -User "$env:computername\inforeliance" -Password "P@ssword123"

#STEP 3: BIOS INSTALL BASED ON COMPUTER 

$BIOS = GWMI win32_BIOS
if((Get-WmiObject -Class:Win32_ComputerSystem).model -eq "Inspiron 13-7359" -And $BIOS.SMBIOSBIOSVERSION -eq "01.08.00")
{
    shutdown /r /t 0
}

elseif((Get-WmiObject -Class:Win32_ComputerSystem).model -eq "Inspiron 13-7359" -And $BIOS.SMBIOSBIOSVersion -ne "01.08.00")
{
    C:\Users\inforeliance\Desktop\WS-01.08.00.exe /s /r
}
elseif((Get-WmiObject -Class:Win32_ComputerSystem).model -eq "Latitude E7450" -And $BIOS.SMBIOSBIOSVersion -eq "Whatever newestvLatitude BIOS is")
{
    shutdown /r /t 0
}
elseif((Get-WmiObject -Class:Win32_ComputerSystem).model -eq "Latitude E7450" -And $BIOS.SMBIOSBIOSVersion -ne "Whatever newest Latitude BIOS is")
{
    C:\Users\inforeliance\Desktop.\LatitudeBIOSis.exe
}
elseif((Get-WmiObject -Class:Win32_ComputerSystem).model -eq "Lenovo Computer" -And $BIOS.SMBIOSBIOSVersion -eq "Whatever newest Lenovo Model BIOS is")
{
    shutdown /r /t 0
}
elseif((Get-WmiObject -Class:Win32_ComputerSystem).model -eq "Lenovo Computer" -And $BIOS.SMBIOSBIOSVersion -ne "Whatever newesr Lenovo Model BIOS is")
{
     C:\Users\inforeliance\Desktop.\LENOVOBIOS.exe
}

Restart-Computer