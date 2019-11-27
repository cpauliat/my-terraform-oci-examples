# --------- Get the OCID for the most recent for Oracle Linux 7.x disk image
data "oci_core_images" "ImageOCID-ol7" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "7.7"

  # filter to avoid Oracle Linux 7.x images for GPU
  filter {
    name   = "display_name"
    values = ["^.*Oracle-Linux-7.7-[^G].*$"]
    regex  = true
  }
}

# ------ Create a compute instance from the most recent Oracle Linux 7.x image
resource "oci_core_instance" "tf-demo20-ol7" {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "tf-demo20-ol7-dbclient"
  shape                = "VM.Standard2.1"
  preserve_boot_volume = "false"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.tf-demo20-public-subnet1.id
    hostname_label = "dbclient"
    #  private_ip    = "10.0.0.3"
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file_ol7)
    user_data           = base64encode(file(var.BootStrapFile_ol7))
  }
}

resource "local_file" "sshconfig" {
  content = <<EOF
Host dbclient-opc
          Hostname ${oci_core_instance.tf-demo20-ol7.public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_ol7}
Host dbclient-oracle
          Hostname ${oci_core_instance.tf-demo20-ol7.public_ip}
          User oracle
          IdentityFile ${var.ssh_private_key_file_ol7}
EOF


  filename = "sshcfg"
}

# ------ Display the complete ssh command needed to connect to the instance
output "DB_client" {
  value = <<EOF

  Connection to Database client (Oracle Linux 7 instance with Oracle Instant Client 18.3)

  as user opc   :   ssh -F sshcfg dbclient-opc

  as user oracle:   ssh -F sshcfg dbclient-oracle

  You need to donwload the Client Credentials (Wallet) from ADB service Console
  and then run the following commands to finish configuration

  scp -F sshcfg <Wallet_xxx>.zip dbclient-oracle:/home/oracle/wallet.zip
  ssh -F sshcfg dbclient-oracle "cd /home/oracle/credentials_adb; unzip ../wallet.zip"
  ssh -F sshcfg dbclient-oracle "sed -i.bak 's#?/network/admin#/home/oracle/credentials_adb#' /home/oracle/credentials_adb/sqlnet.ora"

EOF

}
