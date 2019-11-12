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
- after provisioning, print instructions to connect to the Linux compute instance (SSH)

Last update: September 5, 2019
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