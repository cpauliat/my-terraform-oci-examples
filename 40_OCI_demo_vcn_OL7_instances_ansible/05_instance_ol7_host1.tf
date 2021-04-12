# ------ Create a compute instance from the most recent Oracle Linux 7.x image
resource oci_core_instance tf-demo40-host1 {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "tf-demo40-host1"
  shape                = "VM.Standard.E2.1"
  preserve_boot_volume = "false"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.tf-demo40-public-subnet1.id
    hostname_label = var.host1_hostname
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file_host1)
    # no cloud-init post provisioning (done by Ansible from ansible server)
  }
}

# ------ Display the complete ssh command needed to connect to the instance
output Instance_HOST1 {
  value = <<EOF


  ---- You can SSH directly to the HOST1 instance by typing the following ssh command
  ssh -i ${var.ssh_private_key_file_host1} opc@${oci_core_instance.tf-demo40-host1.public_ip}

  ---- Alternatively, you can add the following lines to your file $HOME/.ssh/config and then just run "ssh d40host1"

  Host d40host1
          Hostname ${oci_core_instance.tf-demo40-host1.public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_host1}

  
EOF

}

