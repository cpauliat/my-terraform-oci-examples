#ps1_sysnative

# ---------- Post-provisioning Cloud-init script for Windows 2016

# cloud-init log file = C:\Program Files\Cloudbase Solutions\Cloudbase-Init\log\cloudbase-init.log

# -- Also log outputs to another log file
Start-Transcript -Path "C:\users\opc\cloud-init.log" -NoClobber

Write-Output "======== Get argument(s) passed thru metadata"
$fs_label=$($(Invoke-WebRequest -UseBasicParsing -Uri http://169.254.169.254/opc/v1/instance/metadata).Content|ConvertFrom-Json).myarg_fs_label

Write-Output "======== Wait for the Block volume to be attached"
Start-Sleep -seconds 60

Write-Output "======== Creating a partition and filesystem on the block volume"
Get-Disk -Number 1 | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel $fs_label -Confirm:$false

Write-Output "======== Disable password expiry (42 days by default)"
net accounts /maxpwage:unlimited 

