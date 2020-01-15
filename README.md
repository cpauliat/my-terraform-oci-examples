# Some Terraform demo config files I created for OCI

Prequisites: Terraform 0.12 or later

To use the demos:
1) Get a copy of the Terraform files by downloading then unzipping file
   https://github.com/cpauliat/my-terraform-oci-examples/archive/master.zip
2) Install Terraform on your machine
3) Create an API key for your user in the CloudUI/console of your OCI tenancy
(see https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm)
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
- 1 compute instance Oracle Linux 7 with public IP and Cloud-init post provisioning actions 
- 1 compute instance MS Windows 2016 with public IP and Cloud-init post provisioning actions passing arguments
- after provisioning, print instructions to connect to the compute instances (SSH for Linux, RDP for Windows)

Last update: December 17, 2019
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
- get name, shape, hostname and post-provisioning from array variables 
- after provisioning, print instructions to connect to the compute instances (SSH for Linux, RDP for Windows)

Last update: January 9, 2020
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

Last update: December 30, 2019
```

### 06_OCI_demo_vcn_OL7_dev_image_pv

```
Summary: basic VCN + 1 compute instance from Oracle Linux Cloud developer image 19.11 

Details:
- 1 VCN with 1 public AD-specific subnet + 1 internet gateway + 1 route table + 1 security list
- 1 VM instance from Oracle Linux Cloud Developer image 19.11 with public IP and block storage (PV attached)
- after provisioning, print instructions to connect to the Linux compute instance (SSH)

Note: see https://console.eu-frankfurt-1.oraclecloud.com/marketplace/application/54030984/overview for more details about this image

Last update: November 27, 2019
```

### 09_OCI_demo_vcn_VirtualBox_VNC

```
Summary: Install VirtualBox and VNC (secured thru SSH tunnel) on a Bare Metal compute instance

Details:
- 1 VCN with 1 public regional subnet + 1 internet gateway + 1 route table + 1 security list
- 1 compute instance Oracle Linux 7 (public IP) on a Bare Metal server BM.Standard2.52
- 1 block volume (iscsi attached to the compute instance) to store VirtualBox images with remote-exec iscsi commands
- 1 Shell script (Linux/MacOS) you can use to create a SSH Tunnel for VNC secure communication
- after instance provisioning, automatically install and configure VirtualBox and VNC (remote desktop) on the instance

Note: As VNC traffic is not encrypted, use a SSH tunnel to access the remote Desktop

Last update: December 18, 2019
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

### 14_OCI_demo_modules

```
Summary: basic example showing how to use Terraform modules

Details:
- 2 basics VCNs 
- 1 compute instance Oracle Linux 7 (public IP) in 1st VCN

Last update: December 5, 2019
```

### 15_OCI_demo_filesystems

```
Summary: file storage example with Oracle Linux 7 and Microsoft Windows 2016

Details:
- 1 VCN with 1 public regional subnet + 1 internet gateway + 1 route table + 1 security list
- 1 compute instance Oracle Linux 7 with public IP address
- 1 compute instance MS Windows 2016 with public IP address
- cloud-init post provisioning task: NFS mount the filesystem on both instances

Last update: December 30, 2019
```

### 17_OCI_demo_vcn_OKE_managed_Kubernetes

```
Summary: Oracle Container Engine (OKE / managed Kubernetes) example

Details:
- 1 VCN with 1 internet gateway + 1 route table + 1 security list
- 1 public regional subnet for Kubernetes worker nodes + 1 public regional subnet for load balancer
- 1 Kubernetes cluster with 1 node pool containing 3 worker nodes (Oracle Linux 7.7)

Last update: January 15, 2020
```

### 20_OCI_demo_autonomous_DB_serverless_SIMPLE

```
Summary: Serverless Autonomous Database instance (ATP or ADW)

Details:
- 1 Serverless Autonomous Database instance (shared): ATP or ADW with password generated using random provider
- 1 VCN with 1 public regional subnet + 1 internet gateway + 1 route table + 1 security list
- 1 compute instance Oracle Linux 7 (public IP) with Oracle Instant Client 18.3 installed by cloud-init
- manual download of wallet file and manual configuration for sqlplus access

Last update: November 27, 2019
```

### 21_OCI_demo_autonomous_DB_serverless_ADVANCED

```
Summary: Serverless Autonomous Database instance (ATP or ADW) with ACL for VCN and automatic SQLplus configuration  

Details:
- 1 Serverless Autonomous Database instance (shared): ATP or ADW with password generated using random provider
- 1 VCN with:
  - 1 public regional subnet + 1 internet gateway + 1 route table + 1 security list for BASTION HOST
  - 1 private regional subnet + 1 NAT gateway + 1 service gateway + 1 route table + 1 security list for DB CLIENT HOST
- 1 compute instance (DB CLIENT) Oracle Linux 7 (private IP) with Oracle Instant Client 18.5 or 19.3 installed by cloud-init
- 1 compute instance (BASTION HOST) Oracle Linux 7 (public IP) 
- automatic download of wallet file and automatic configuration of sqlplus using cloud-init

Last update: November 27, 2019
```

### 26_OCI_demo_DNS_webserver_https

```
Summary: Domain Name Resolution (DNS)

Details:
- 1 VCN with 1 public regional subnet + 1 internet gateway + 1 route table + 1 security list
- 1 compute instance Oracle Linux 7 (public IP) with NGINX Web server
- 1 DNS zone with 1 DNS record (type A) for the public IP address
- NGINX Web server automatically configured with SSL certificate (HTTPS) using certbot from letsencrypt.org
- New NGINX welcome page (zip file pushed by Terraform file provisioner and extract by remote-exec provisioner)

Prerequisite: 
- Register a public DNS domain (in my case, I use freenom.com with free domain) and delegate name resolution to OCI DNS zone.

Last update: October 22, 2019
```

### 34_OCI_demo_SGD_marketplace

```
Summary: HTTPS Remote Desktop using Oracle Secure Global Desktop from OCI Marketplace

Details:
- 1 VCN with:
  - 1 public regional subnet + 1 internet gateway + 1 route table + 1 security list 
  - 1 private regional subnet + 1 NAT gateway + 1 service gateway + 1 route table + 1 security list 
- 1 compute instance (DESKTOP) Oracle Linux 7 (private IP) with cloud-init post-provisioning tasks
- 1 compute instance (SGD HOST) Oracle Linux 7 (public IP) with cloud-init post-provisioning tasks
  including creation and publishing of new SGD applications for the DESKTOP instance

Last update: December 12, 2019
```

### 35_OCI_demo_remote_desktop_noVNC

```
Summary: HTTPS Remote Desktop Oracle Linux 7 using noVNC WebUI (no VNC client needed) 

Details:
- 1 VCN with 1 public regional subnet + 1 internet gateway + 1 route table + 1 security list 
- 1 compute instance (DESKTOP) Oracle Linux 7 with cloud-init post-provisioning tasks:
  + install and configure VNC server (including VNC password from random string)
  + install and configure noVNC with HTTPS self signed certificate

Last update: December 18, 2019
```

### 36_OCI_demo_vcn_OL8_cockpit

```
Summary: HTTPS Cockpit Web interface on Oracle Linux 8

Details:
- 1 VCN with 1 public regional subnet + 1 internet gateway + 1 route table + 1 security list 
- 1 compute instance Oracle Linux 8 with cloud-init post-provisioning tasks:
  + install and configure Cockpit Web Interface
  + create a new Linux user (with random password) to connect to Cockpit Web Interface

Last update: December 30, 2019
```

### 38_OCI_demo_vcn_count_subnets

```
Summary: basic VCN + several subnets using count

Details:
- 1 VCN with 1 internet gateway + 1 route table + 1 security list and n subnets
- get name, cidr, dnslabem of subnets from array variables 

Last update: January 9, 2020
```