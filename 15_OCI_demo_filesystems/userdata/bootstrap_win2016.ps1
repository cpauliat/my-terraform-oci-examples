#ps1_sysnative

# ---------- Post-provisioning Cloud-init script for Windows 2016

# cloud-init log file = C:\Program Files\Cloudbase Solutions\Cloudbase-Init\log\cloudbase-init.log
# commands executed by local user cloudbase-init

# -- Also log outputs to another log file
Start-Transcript -Path "C:\users\opc\cloud-init.log" -NoClobber

Write-Output "======== Get argument(s) passed thru metadata"
$password=$($(Invoke-WebRequest -UseBasicParsing -Uri http://169.254.169.254/opc/v1/instance/metadata).Content|ConvertFrom-Json).myarg_password 
$fs_export_path=$($(Invoke-WebRequest -UseBasicParsing -Uri http://169.254.169.254/opc/v1/instance/metadata).Content|ConvertFrom-Json).myarg_fs_export_path
$nfs_ip=$($(Invoke-WebRequest -UseBasicParsing -Uri http://169.254.169.254/opc/v1/instance/metadata).Content|ConvertFrom-Json).myarg_fs_ip_address
$drive=$($(Invoke-WebRequest -UseBasicParsing -Uri http://169.254.169.254/opc/v1/instance/metadata).Content|ConvertFrom-Json).myarg_nfs_drive

Write-Output "======== Set a password for opc user (replace temporary randomly generated password)"
net user opc $password  

Write-Output "======== Create new user account opc2 with Administrators privileges (may be needed if opc is locked)"
net user opc2 $password /add   
net localgroup  administrators opc2 /add  

Write-Output "======== Disable password expiry (42 days by default)"
net accounts /maxpwage:unlimited 

Write-Output "======== Install NFS client"
Install-WindowsFeature NFS-Client,RSAT-NFS-Admin
# To check if NFS client installed, type: Get-WindowsFeature -Name NFS*

# TO DO: Map NFS network drive for user opc

#$user = "opc"
#$pwd = ConvertTo-SecureString "-k_y74TUClKe" -AsPlainText -Force
#$cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($user, $pwd)