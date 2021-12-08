## IMPORTANT : PREREQUISITES BEFORE RUNNING TERRAFORM APPLY

1. Create a reserved public IP using OCI console
   then put the OCID of reserved public IP in file terraform.tfvars
2. Create an official DNS hostname for the reserved public IP (for instance using freenom.com). Wait a few minutes until the DNS hostname is propagated to Internet DNS servers (check with nslookup)

3. Create an official certificate signed by a real CA (for instance using free 90 days certificates at https://sslforfree.com), then download the 3 files needed (certificate for the LB, CA certificate and private key) in the cert folder
4. Update terraform.tfvars
