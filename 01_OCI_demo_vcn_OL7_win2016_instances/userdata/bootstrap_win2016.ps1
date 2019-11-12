#ps1_sysnative

# ---------- Post-provisioning Cloud-init script for Windows 2016

# -- Set a password for opc user (replace temporary randomly generated password)
net user opc "OCIpwd#2019#"

# -- Create new user account opc2 with Administrators privileges (may be needed if opc is locked)
net user opc2 "OCIpwd#2019#" /add
net localgroup  administrators opc2 /add

# -- Disable password expiry (42 days by default)
net accounts /maxpwage:unlimited

