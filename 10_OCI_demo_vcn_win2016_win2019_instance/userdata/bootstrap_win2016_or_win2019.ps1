#ps1_sysnative

# ---------- Post-provisioning Cloud-init script for Windows 2016

# cloud-init log file = C:\Program Files\Cloudbase Solutions\Cloudbase-Init\log\cloudbase-init.log

# -- Also log outputs to another log file
Start-Transcript -Path "C:\users\opc\cloud-init.log" -NoClobber 

Write-Output "======== Create a new standard local user account"
net user user01 TH1S_1s_my_PWD /add   
net localgroup "remote desktop users" user01 /add  

Write-Output "======== Create a new local user opc2 with Administrators privileges (may be needed if opc is locked)"
net user opc2 TH1S_1s_my_PWD /add
net localgroup  administrators opc2 /add

Write-Output "======== Disable password expiry (42 days by default)"
net accounts /maxpwage:unlimited 

