# Some Terraform demo config files I created for OCI

Prequisites: Terraform 0.12 or later

To use the demos:
1) Get a copy of the Terraform files by downloading then unzipping file https://github.com/cpauliat/my-terraform-oci-examples/archive/master.zip
2) Install Terraform on your machine
3) Create an API key for your user in the CloudUI/console of your OCI tenancy
(see https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm.
You can use my script available at https://github.com/cpauliat/my-oci-scripts/blob/master/generate_api_keys.sh)
4) Cd to one of the demo folders
5) Copy file **terraform.tfvars.template** to **terraform.tfvars**
6) Edit and update file terraform.tfvars for this demo
7) run `terraform init` command in the folder containing .tf files (only needed once before first test)
8) run `terraform plan` to see what actions will be done (dry run)
9) run `terraform apply` to execute those actions and provision the infrastructure
10) Finally, run `terraform destroy` to delete objects created previously with `terraform apply`

### 01_OCI_demo_vcn_OL7_win2016_instances

```
Summary: basic VCN + basic compute instances for Oracle Linux 7 and Microsoft Windows Server 2016

Details:
- 1 VCN with 1 public regional subnet + 1 internet gateway + 1 route table + 1 security list
- 1 compute instance Oracle Linux 7 with public IP and Cloud-init post provisioning actions (without block volume)
- 1 compute instance MS Windows 2016 with public IP and Cloud-init post provisioning actions (without block volume)
- after provisioning, print instructions to connect to the compute instances (SSH for Linux, RDP for Windows)

Last update: September 5, 2019
```

### 02_OCI_demo_vcn_OL7_block_volumes_pv

```
Summary: basic VCN + 1 compute instance with block volumes (paravirtualized attachment)

Details:
- 1 VCN with 1 public AD-specific subnet + 1 internet gateway + 1 route table + 1 security list
- 1 VM  instance Oracle Linux 7 with public IP with 1 block volume (attached in paravirtualized mode)
- post provisioning tasks with cloud-init, passing arguments to cloud-init script.
- after provisioning, print instructions to connect to the Linux compute instance (SSH)

Last update: November 12, 2019
```

### 03_OCI_demo_vcn_OL7_count

```
Summary: basic VCN + several identical compute instances for Oracle Linux 7 using "count"

Details:
- 1 VCN with 1 public regional subnet + 1 internet gateway + 1 route table + 1 security list
- several compute instances Oracle Linux 7 with public IP and Cloud-init post provisioning actions (without block volume)
- after provisioning, print instructions to connect to the compute instances (SSH for Linux, RDP for Windows)

Last update: November 19, 2019
```

### 04_OCI_demo_vcn_OL7_security_groups

```
Summary: basic VCN + 1 network security group (NSG) + 1 compute instance using the NSG

Details:
- 1 VCN with 1 public AD-specific subnet + 1 internet gateway + 1 route table + 1 empty security list + 1 network security list
- 1 VM instance Oracle Linux 7 with public IP with 1 VNIC connected to the network security group
- Oracle Database Instant Client (18.5 or 19.5) installed with cloud-init post-provisioning
- after provisioning, print instructions to connect to the Linux compute instance (SSH)

Last update: November 27, 2019
```

### 05_OCI_demo_vcn_DB_VM_remote-exec

```
Summary: basic VCN + public subnet + DB SYSTEM (VM shape) + OCI filesystem + remote-exec provisioner

Details
- 1 VCN with 1 public regional subnet + 1 internet gateway + 1 route table + 1 security list
- 1 DB system on VM.Standard* shape with 1 DB instance
- 1 filesystem (File Storage) that will be used on the DB system to store staging files, backups...
- Filesystem NFS-mounted automatically on the DB system using remote-exec provisioner

Last update: November 7, 2019
```

### 12_OCI_demo_vcn_peering_local

```
Summary: Local VCN peering between 2 VCNs in same tenant and same region

Details:
- 2 VCNs with following objects in each:
  1 public regional subnet + 1 internet gateway + 1 route table + 1 security list
- Local VCN peering configured between the 2 VCNs
- 2 compute instances Oracle Linux 7 (public IP), 1 per VCN
- after instances provisioning, you can test access (ping) between the 2 instances in different VCNs

Reminder: the 2 VCNs must have non overlapping CIDRs

Last update: September 9, 2019
```

### 13_OCI_demo_vcn_peering_local

```
Summary: Remote VCN peering between 2 VCNs in same tenant but different regions

Details:
- 2 VCNs with following objects in each:
  1 public regional subnet + 1 private regional subnet + 1 internet gateway + 2 route tables + 2 security lists
- Remote VCN peering configured between the 2 VCNs.
- 2 compute instances Oracle Linux 7 (public IP), 1 per VCN
- after instances provisioning, you can test access (ping) between the 2 instances in different VCNs / REGIONs

Reminder: the 2 VCNs must have non overlapping CIDRs

Last update: September 9, 2019
```

### 20_OCI_demo_autonomous_DB_serverless

```
Summary: Serverless Autonomous Database instance (ATP or ADW)

Details:
- 1 Serverless Autonomous Database instance (shared): ATP or ADW with password generated using random provider
- 1 VCN with 1 public regional subnet + 1 internet gateway + 1 route table + 1 security list
- 1 compute instance Oracle Linux 7 (public IP) with Oracle Instant Client 18.3 installed by cloud-init

Last update: November 19, 2019
```

### 21_OCI_demo_autonomous_DB_serverless_VCN_ACL

```
Summary: Serverless Autonomous Database instance (ATP or ADW) with access control list for VCN (more secure)  

Details:
- 1 Serverless Autonomous Database instance (shared): ATP or ADW with password generated using random provider
- 1 VCN with:
  - 1 public regional subnet + 1 internet gateway + 1 route table + 1 security list for BASTION HOST
  - 1 private regional subnet + 1 NAT gateway + 1 service gateway + 1 route table + 1 security list for DB CLIENT HOST
- 1 compute instance (DB CLIENT) Oracle Linux 7 (private IP) with Oracle Instant Client 18.5 or 19.3 installed by cloud-init
- 1 compute instance (BASTION HOST) Oracle Linux 7 (public IP) 

Last update: November 27, 2019
```