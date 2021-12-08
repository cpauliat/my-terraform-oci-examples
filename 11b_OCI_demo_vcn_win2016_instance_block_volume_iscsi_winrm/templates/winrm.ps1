#ps1_sysnative

Write-Output "======== Attach iSCSI Block volume"
$ipv4='${volume_ipv4}'
$iqn='${volume_iqn}'
Set-Service -Name msiscsi -StartupType Automatic
Start-Service msiscsi
New-IscsiTargetPortal -TargetPortalAddress $ipv4
Connect-IscsiTarget -NodeAddress $iqn -TargetPortalAddress $ipv4 -IsPersistent $True

Write-Output "======== Create a partition and filesystem on the iSCSI block volume"
Get-Disk -Number 1 | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "blockvol" -Confirm:$false
