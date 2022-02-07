#ps1_sysnative

# ---------- Post-provisioning Cloud-init script for Windows 2016

# cloud-init log file = C:\Program Files\Cloudbase Solutions\Cloudbase-Init\log\cloudbase-init.log

# -- Also log outputs to another log file
Start-Transcript -Path "C:\users\opc\cloud-init.log" -NoClobber

Write-Output "======== Get argument(s) passed thru metadata"
$password=$($(Invoke-WebRequest -UseBasicParsing -Uri http://169.254.169.254/opc/v1/instance/metadata).Content|ConvertFrom-Json).myarg_password 

Write-Output "======== Set a password for opc user (replace temporary randomly generated password)"
net user opc $password  

Write-Output "======== Create new user account opc2 with Administrators privileges (may be needed if opc is locked)"
net user opc2 $password /add   
net localgroup administrators opc2 /add  

Write-Output "======== Disable password expiry (42 days by default)"
net accounts /maxpwage:unlimited 

Write-Output "======== Create temporary folder"
mkdir C:\temp

Write-Output "======== Download and Install Firefox web browser"
wget "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-US" -OutFile c:\temp\setup_firefox.exe
start-process -FilePath 'c:\temp\setup_firefox.exe' -ArgumentList '/S' -wait

Write-Output "======== Download and Install Filezilla"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
wget "https://download.filezilla-project.org/client/FileZilla_latest_win64-setup.exe" -OutFile c:\temp\setup_filezilla.exe
start-process -FilePath 'c:\temp\setup_filezilla.exe' -ArgumentList '/S' -wait

Write-Output "======== Download and Install Notepad++"
wget "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.2.1/npp.8.2.1.Installer.x64.exe" -OutFile c:\temp\setup_npp.exe
start-process -FilePath 'c:\temp\setup_npp.exe' -ArgumentList '/S' -wait

Write-Output "======== Create a powershell script to be manually run by opc user (run Powershell terminal as Administrator) on first connection"

$string = @'
Write-Output "IMPORTANT: MAKE SURE TO RUN THIS SCRIPT IN A POWERSHELL TERMINAL RUNNING AS ADMINISTRATOR"

Write-Output "======== Download and install OCI cli"
Set-ExecutionPolicy RemoteSigned
wget "https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.ps1" -OutFile c:\temp\install.ps1
powershell -ExecutionPolicy Bypass c:\temp\install.ps1 -AcceptAllDefaults

Write-Output "======== Display file extensions in Windows explorer"
$key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Set-ItemProperty $key Hidden 1 -Force
Set-ItemProperty $key HideFileExt 0 -Force
Set-ItemProperty $key ShowSuperHidden 1 -Force
Stop-Process -processname explorer

#Write-output "======== Pin some applications to Task bar (TO BE FIXED)"
#$sa = new-object -c shell.application
#$pn = $sa.namespace('C:\Program Files\Mozilla Firefox').ParseName('firefox.exe')
#$pn.invokeverb('taskbarpin')

Write-Output "======== End of script"
pause
'@

New-Item C:\temp\final_run_as_administrator.ps1
Set-Content C:\temp\final_run_as_administrator.ps1 $string

