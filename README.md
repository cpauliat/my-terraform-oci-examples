# Some Terraform demo config files I created for OCI

Prequisites: Terraform 0.12 or later

To use the demos:

1. Get a copy of the Terraform files by downloading then unzipping file
   https://github.com/cpauliat/my-terraform-oci-examples/archive/master.zip
2. Install Terraform on your machine
3. Create an API key for your user in the CloudUI/console of your OCI tenancy
   (see https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm)
   You can use my script available at https://github.com/cpauliat/my-oci-scripts/blob/master/generate_api_keys.sh)
4. Cd to one of the demo folders
5. Copy file **terraform.tfvars.template** to **terraform.tfvars**
6. Edit and update file terraform.tfvars for this demo
7. run `terraform init` command in the folder containing .tf files (only needed once before first test)
8. run `terraform plan` to see what actions will be done (dry run)
9. run `terraform apply` to execute those actions and provision the infrastructure
10. Finally, run `terraform destroy` to delete objects created previously with `terraform apply`

### 01_OCI_demo_vcn_OL7_instance

```
Summary: basic VCN + basic Oracle Linux 7 compute instance

Details:
- 1 VCN with 1 public regional subnet + 1 internet gateway + 1 route table + 1 security list
- 1 compute instance Oracle Linux 7 with public IP and Cloud-init post provisioning actions
- after provisioning, print instructions to connect to the compute instance

Last update: January 28, 2020
```

### 01b_OCI_demo_vcn_OL7_instance_with_generated_ssh_key

```
Summary: basic VCN + basic compute instance for Oracle Linux 7 with SSH keys generated by Terraform

Details:
- 1 VCN with 1 public regional subnet + 1 internet gateway + 1 route table + 1 security list
- 1 compute instance Oracle Linux 7 with public IP and Cloud-init post provisioning actions
- after provisioning, print instructions to connect to the compute instances (SSH for Linux)

Last update: January 20, 2020
```

### 02_OCI_demo_vcn_OL7_block_volumes_pv

```
Summary: basic VCN + 1 compute instance Oracle Linux 7 with block volumes (paravirtualized attachment)

Details:
- 1 VCN with 1 public AD-specific subnet + 1 internet gateway + 1 route table + 1 security list
- 1 VM compute instance Oracle Linux 7 with public IP with 1 block volume (attached in paravirtualized mode)
- post provisioning tasks with cloud-init, passing arguments to cloud-init script.
- after provisioning, print instructions to connect to the Linux compute instance (SSH)

Last update: June 8, 2021
```

### 02b_OCI_demo_vcn_OL7_block_volumes_iscsi_remote_exec

```
Summary: basic VCN + 1 compute instance Oracle Linux 7 with block volumes (iscsi attachment)

Details:
- 1 VCN with 1 public regional subnet + 1 internet gateway + 1 route table + 1 security list
- 1 VM compute instance Oracle Linux 7 with public IP with 1 block volume (attached in iscsi mode)
- post provisioning tasks with cloud-init, passing arguments to cloud-init script.
- post provisioning tasks for iscsi commands to complete block volume attachementwith remote-exec
- after provisioning, print instructions to connect to the Linux compute instance (SSH)

Last update: June 22, 2020
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

Last update: August 5, 2020
```

### 05b_OCI_demo_vcn_DB_BM_dataguard

```
Summary: basic VCN + public subnet + 2 DB SYSTEMS (bare metal shape) + Data Guard enabled for DB instance in DBS #1

Details
- 1 VCN with 1 public regional subnet + 1 internet gateway + 1 route table + 1 security list
- 2 DB systems in different availability domains on bare metal BM.DenseIO2.52 shape with 1 DB instance each (DB1 and DB2)
- Data Guard enabled on DB1 (creates DB1 standby instance in DB system #2)
- Copy local file to remote DB system using file provisioner

Last update: August 5, 2020
```

## 05c_OCI_demo_vcn_DB_VM_dataguard

```
Summary: basic VCN + public subnet + DB SYSTEM (VM shape) in same region

Details
- 1 VCN with 1 public regional subnet + 1 internet gateway + 1 route table + 1 security list
- 1 DB system on VM.Standard* shape with 1 DB instance
- Dataguard enabled on DB system (creates second VM DB system in SAME REGION, SAME VCN and SAME SUBNET)

Last update: August 05, 2020
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

### 07a_OCI_demo_vcn_LB_public

```
Summary: 1 VCN + 3 compute instances (2 web servers + 1 bastion) + 1 public load balancer for HTTP

Details:
- 1 VCN with 1 public regional subnet and 1 private regional subnet
- 2 compute instances for web servers in private subnet with HTTP web server
- 1 compute instance for bastion host
- 1 public load balancer with HTTP listener on port 80
- after provisioning, print instructions for connections (HTTP and SSH connections)

Last update: August 6, 2020
```

### 07b_OCI_demo_vcn_LB_public_path_routing

```
Summary: 1 VCN + 3 compute instances (2 web servers + 1 bastion) + 1 public load balancer for HTTP with path route set

Details:
- 1 VCN with 1 public regional subnet and 1 private regional subnet
- 2 compute instances for web servers in private subnet with HTTP web server
- 1 compute instance for bastion host
- 1 public load balancer with HTTP listener on port 80 with path route set
  (/app1 directed to web server 1 and /app2 directed to web server 2)
- after provisioning, print instructions for connections (HTTP and SSH connections)

Last update: April 21, 2021
```

### 07c_OCI_demo_vcn_LB_public_SSL_termination

```
Summary: 1 VCN + 3 compute instances (2 web servers + 1 bastion) + 1 public load balancer with HTTPS enabled for the load balancer with SSL termination

Details:
- 1 VCN with 1 public regional subnet and 1 private regional subnet
  Note: using Terraform dynamic blocks for the ingress rules in security list
- 2 compute instances for web servers in private subnet with HTTP web server
- 1 compute instance for bastion host
- 1 public load balancer with HTTPS listener on port 443 with official certificate
- after provisioning, print instructions for connections (HTTP and SSH connections)

Last update: April 21, 2021
```

### 07d_OCI_demo_vcn_LB_hostnames

```
Summary: 1 VCN + 6 compute instances (5 web servers + 1 bastion) + 1 public load balancer with routing using virtual hostnames

Details:
- 1 VCN with 1 public regional subnet and 1 private regional subnet
  Note: using Terraform dynamic blocks for the ingress rules in security list
- 1 public load balancer
- 1 backends set for virtual hostname #1 (2 compute instances web servers)
- 1 backends set for virtual hostname #1 (2 compute instances web servers)
- 1 backends set for default (1 compute instances web server)
- 3 load balancer listeners (1 per backend set)
- 2 virtual hostnames
- 1 compute instance for bastion host
- after provisioning, print instructions for connections (HTTP and SSH connections)

Last update: April 21, 2021
```

### 07e_OCI_demo_vcn_NLB_public

```
Summary: 1 VCN + 3 compute instances (2 web servers + 1 bastion) + 1 public Network load balancer

Details:
- 1 VCN with 1 public regional subnet and 1 private regional subnet
- 2 compute instances for web servers in private subnet with HTTP web server
- 1 compute instance for bastion host
- 1 public NETWORK load balancer with listener on port 80
- after provisioning, print instructions for connections (HTTP and SSH connections)

Last update: April 21, 2021
```

### 07f_OCI_demo_vcn_LB_routing_policies

```
Summary: 1 VCN + 6 compute instances (5 web servers + 1 bastion) + 1 public load balancer with routing using virtual hostnames

Details:
- 1 VCN with 1 public regional subnet and 1 private regional subnet
  Note: using Terraform dynamic blocks for the ingress rules in security list
- 1 public load balancer
- 1 routing policy using path route
- 1 backends set for route /route1 (2 compute instances web servers)
- 1 backends set for route /route2 (2 compute instances web servers)
- 1 backends set for default (1 compute instances web server)
- 1 load balancer listener using the routing policy
- 1 compute instance for bastion host
- after provisioning, print instructions for connections (HTTP and SSH connections)

Last update: April 21, 2021
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

### 10_OCI_demo_vcn_win2016_instance

```
Summary: basic VCN + basic Microsoft Windows Server 2016/2019 compute instance

Details:
- 1 VCN with 1 public regional subnet + 1 internet gateway + 1 route table + 1 security list
- 1 compute instance MS Windows 2016/2019 with public IP and Cloud-init post provisioning
- after provisioning, print instructions to connect to the compute instance

Last update: July 10, 2020
```

### 10b_OCI_demo_vcn_win2016_instance_pwd_changed_simple

```
Summary: basic VCN + basic Microsoft Windows Server 2016 compute instance with new random password

Details:
- Same as 10_OCI_demo_vcn_win2016_instance except the fact that a new random password is set with cloud-init,
  replacing the temporary password
- Please note that the generated password is passed to cloud-init script using metadata which is simple but NOT SECURE.
  If you plan to keep the compute instance, you need to change the password for user opc and opc2
- Provisioning: install Firefox, Filezilla, Notepad++ and OCI CLI, and display file extensions in File explorer.

Last update: July 10, 2020
```

### 10c_OCI_demo_vcn_win2016_instance_pwd_changed_secure

```
Summary: basic VCN + basic Microsoft Windows Server 2016 compute instance with new random password

Details:
- Same as 10b_OCI_demo_vcn_win2016_instance_pwd_changed_simple except the fast that a new random password is set with cloud-init,
  replacing the temporary password
- Please note that the generated password is passed to cloud-init script using OCI object storage which is more complex than metadata but more SECURE.

Last update: April 1, 2020
```

### 11_OCI_demo_vcn_win2016_block_volumes_pv

```
Summary: basic VCN + 1 compute instance Microsoft Windows Server 2016 with block volumes (paravirtualized attachment)

Details:
- 1 VCN with 1 public regional subnet + 1 internet gateway + 1 route table + 1 security list
- 1 VM compute instance Microsoft Windows Server 2016 with public IP with 1 block volume (attached in paravirtualized mode)
- post provisioning tasks with cloud-init, passing arguments to cloud-init script.
- after provisioning, print instructions to connect to the compute instance (RDP)

Last update: January 28, 2020
```

### 11b_OCI_demo_vcn_win2016_instance_block_volume_iscsi_winrm

```
Summary: basic VCN + 1 compute instance Microsoft Windows Server 2016 with block volumes (iscsi attachment) + WinRM post-provisioning

Details:
- 1 VCN with 1 public regional subnet + 1 internet gateway + 1 route table + 1 security list
- 1 VM compute instance Microsoft Windows Server 2016 with public IP with 1 block volume (attached in iscsi mode)
- post provisioning tasks with cloud-init, passing arguments to cloud-init script.
- post provisioning tasks also with winrm, passing arguments to winrm script.
- after provisioning, print instructions to connect to the compute instance (RDP)

Last update: March  2, 2020
```

### 12_OCI_demo_vcn_peering_local_LPGs

```
Summary: Local VCN peering between 2 VCNs in same tenant and same region using LPGs (Soon deprecated, see example 12c instead)

Details:
- 2 VCNs with following objects in each:
  1 public regional subnet + 1 internet gateway + 1 route table + 1 security list + 1 local peering gateway (LGP)
- Local VCN peering configured between the 2 VCNs using 2 LPGs
- 2 compute instances Oracle Linux 7 (public IP), 1 per VCN
- DNS resolution between the 2 VCNs.
- after instances provisioning, you can test access (ping using DNS hostnames) between the 2 instances in different VCNs

Reminder: the 2 VCNs must have non overlapping CIDRs

Last update: April 7, 2021
```

### 12b_OCI_demo_vcn_peering_local_2_tenants_1_DRG

```
Summary: Local VCN peering between 2 VCNs in different tenants and same region using 1 DRG

Details:
- same as 12c_OCI_demo_2_vcns_peering_local_1_DRG except we use 2 tenants here

Last update: June 9, 2021
```

### 12c_OCI_demo_2_vcns_peering_local_1_DRG

```
Summary: Local VCN peering between 2 VCNs in same tenant and same region using 1 DRG

Details:
- same as 12_OCI_demo_vcn_peering_local except we use 1 DRG instead of 2 LPGs (improvements May 2021)

Last update: June 1, 2021
```

### 12d_OCI_demo_3_vcns_peering_local_1_DRG

```
Summary: Local VCN peering between 3 VCNs in same tenant and same region using 1 DRG

Details:
- same as 12c_OCI_demo_2_vcns_peering_local_1_DRG except we use 3 VCNs instead of 2

Last update: June 1, 2021
```

### 13_OCI_demo_vcn_peering_local

```
Summary: Remote VCN peering between 2 VCNs in same tenant but different regions

Details:
- 2 VCNs with following objects in each:
  1 public regional subnet + 1 private regional subnet + 1 internet gateway + 2 route tables + 2 security lists
- Remote VCN peering configured between the 2 VCNs.
- 2 compute instances Oracle Linux 7 (public IP), 1 per VCN
- DNS resolver endpoints (listeners and forwarders) and rules to allow DNS resolution between the 2 VCNs
- after instances provisioning, you can test access (ping private IP address or ping private DNS hostnames) between the 2 instances in different VCNs / REGIONs

Reminder: the 2 VCNs must have non overlapping CIDRs

Last update: May 5, 2021
```

### 13b_OCI_demo_vcn_peering_remote_2_tenants

```
Summary: Remote VCN peering between 2 VCNs in different tenants and different regions

Details:
- 2 VCNs with following objects in each:
  1 public regional subnet + 1 private regional subnet + 1 internet gateway + 2 route tables + 2 security lists
- 1 DRG in each tenant, attached to local VCN
- Remote VCN peering configured between the 2 DRG.
- 2 compute instances Oracle Linux 7 (public IP), 1 per VCN
- DNS resolver endpoints (listeners and forwarders) and rules to allow DNS resolution between the 2 VCNs
- after instances provisioning, you can test access (ping private IP address or ping private DNS hostnames) between the 2 instances in different TENANTs / REGIONs

Reminder: the 2 VCNs must have non overlapping CIDRs

Last update: June 9, 2021
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

### 16_OCI_demo_vcn_remote_state_s3

```
Summary: basic VCN with Terraform State file stored in OCI Object Storage bucket using S3 compatibility

Details:
- 1 VCN with 1 public regional subnet + 1 internet gateway + 1 route table + 1 security list
- Terraform state file stored in OCI object storage

Prerequisites:
- Create an object storage bucket in a OCI tenant (can be a different OCI tenant)
- Create a customer secret key for the OCI user, update s3key.template file, then copy it to s3key
- Run terraform init to initialize remote state file

Last update: January 20, 2020
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
- 1 compute instance Oracle Linux 7 (public IP) with Oracle Instant Client 21 installed by cloud-init
- manual download of wallet file and manual configuration for sqlplus access

Last update: July 22, 2021
```

### 21_OCI_demo_autonomous_DB_serverless_ADVANCED

```
Summary: Serverless Autonomous Database instance (ATP or ADW) with ACL for VCN and automatic SQLplus configuration

Details:
- 1 Serverless Autonomous Database instance (shared): ATP or ADW with password generated using random provider
- 1 VCN with:
  - 1 public regional subnet + 1 internet gateway + 1 route table + 1 security list for BASTION HOST
  - 1 private regional subnet + 1 NAT gateway + 1 service gateway + 1 route table + 1 security list for DB CLIENT HOST
- 1 compute instance (DB CLIENT) Oracle Linux 7 (private IP) with Oracle Instant Client 21 installed by cloud-init
- 1 compute instance (BASTION HOST) Oracle Linux 7 (public IP)
- automatic download of wallet file and automatic configuration of sqlplus using cloud-init

Last update: July 22, 2021
```

### 22_OCI_demo_autonomous_DB_serverless_SIMPLE_within_VCN

```
Summary: Serverless Autonomous Database instance (ATP or ADW) with private endpoint in VCN

Details:
- 1 VCN with 1 public regional subnet + 1 internet gateway + 1 route table + 1 security list + 1 network security group
- 1 Serverless Autonomous Database instance (shared) with private endpoint in VCN
  ATP or ADW with password generated using random provider
  https://docs.cloud.oracle.com/en-us/iaas/Content/Database/Concepts/adbsprivateaccess.htm
- 1 compute instance (DB CLIENT) Oracle Linux 7 (public IP) with Oracle Instant Client 21 installed by cloud-init
- automatic download of wallet file and automatic configuration of sqlplus using cloud-init

Last update: July 22, 2021
```

https://docs.cloud.oracle.com/en-us/iaas/Content/Database/Concepts/adbsprivateaccess.htm

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

### 27_OCI_demo_DNS_failover_http

```
Summary: Automatic DNS change using DNS Traffic mgt steering policy (failover mode)

Details:
- 1 VCN with 1 public regional subnet + 1 internet gateway + 1 route table + 1 security list
- 2 compute instances Oracle Linux 7 with public IP acting as primary and secondary web servers
  ngnix installed and welcome page configured using cloud-init and remote-exec post-provisioning tasks
- 1 DNS zone with 1 traffic management steering policy (FAILOVER mode) for DNS hostname

Prerequisite:
- Register a public DNS domain (in my case, I use freenom.com with free domain) and delegate name resolution to OCI DNS zone.

Last update: July 29, 2020
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

### 37_OCI_demo_vcn_OL7_instance_reserved_public_IP

```
Summary: basic VCN + basic compute instance Oracle Linux 7 + reserved public IP

Details:
- 1 VCN with 1 public regional subnet + 1 internet gateway + 1 route table + 1 security list
- 1 compute instance Oracle Linux 7
- 1 reserved public IP assigned to compute instance and protected against destruction (prevent_destroy = true)
- after provisioning, print instructions to connect to the compute instance

Last update: January 21, 2020
```

### 38_OCI_demo_vcn_count_subnets

```
Summary: basic VCN + several subnets using count

Details:
- 1 VCN with 1 internet gateway + 1 route table + 1 security list and n subnets
- get name, cidr, dnslabem of subnets from array variables

Last update: January 9, 2020
```

### 40_OCI_demo_vcn_OL7_instances_ansible

```
Summary: basic VCN + 2 compute instances: 1 Ansible server used to do post-provisioning on a second instance

Details:
- 1 VCN with 1 internet gateway + 1 route table + 1 security list and n subnets
- 1 first Oracle Linux 7 compute instance with Ansible installed, configured and executed with cloud-init
- 1 second Oracle Linux 7 compute instance with post-provisioning done by Ansible playbook from first instance

Last update: March 25, 2020
```

### 41_OCI_demo_vcn_OL7_instance_2_vnics

```
Summary: VCN + 1 compute instance with 2 VNICs

Details:
- 1 VCN with 1 public regional subnet and 1 private regional subnet
- 1 Oracle Linux 7 compute instance with 2 VNICs (primary/default VNIC + additional secondary VNIC)

Last update: July 23, 2020
```

### 46_OCI_demo_vcn_dynamic_security_rules

```
Summary: VCN + 1 public subnet using dynamic block in security list

Details:
- 1 VCN with 1 public regional subnet using 1 security list
- security rules added to security list using dynamic blocks and list of maps variables

Last update: April 2, 2021
```

### 47_OCI_demo_vcn_instances_advanced_features

```
Summary: VCN + subnets + Linux compute instances + bastion using advanced features

Details:
- Several subnets created from details provided in list of maps variables
- Several Linux compute instances created from details provided in list of maps variables
- One block volume (variable size) created and iSCSI attached to each Linux compute instance
- Filesystem created automically on block volumes and mounted automatically on Linux compute instances
- A Linux compute instance for bastion
- sshcfg file created from template to facilitate connections to all compute instance from Internet throught bastion host
- output created from template

Avanced features used:
- dynamic blocks
- list of maps variables
- template files
- count

Last update: April 2, 2021
```

### 48_OCI_demo_vcn_instance_vulnerability_scanning

```
Summary: basic VCN + basic Oracle Linux 7 compute instance + Vulnerability Scanning service enabled for it

Details:
- 1 VCN with 1 public regional subnet + 1 internet gateway + 1 route table + 1 security list
- 1 compute instance Oracle Linux 7 with public IP and Cloud-init post provisioning actions
- after provisioning, print instructions to connect to the compute instance
- Vulnerability Scanning Service (VSS): recipe and target containing the instance

Last update: April 27, 2021
```

### 49_OCI_demo_vcn_private_instance_bastion_aas

```
Summary: 1 VCN + 1 private subnet + Oracle Linux 7 compute instance + Bastion as a service

Details:
- 1 VCN with 1 private regional subnet + 1 NAT gateway + 1 service gateway + 1 route table + 1 security list
- 1 compute instance Oracle Linux 7 on private subnet (without public IP) and Cloud-init post provisioning actions
- 1 OCI Bastion for the private subnet
- 1 session in the OCI Bastion to connect to compute instance from Internet
- after provisioning, print instructions to connect to the compute instance

Last update: June 4, 2021
```
