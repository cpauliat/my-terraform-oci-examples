# --------- Get the OCID for the most recent for Oracle Linux 7.x disk image
data oci_core_images ImageOCID-ol7 {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "7.6"

  # filter to avoid Oracle Linux 7.x images for GPU
  filter {
    name   = "display_name"
    values = ["^.*Oracle-Linux-7.6-[^G].*$"]
    regex  = true
  }
}

# ------ Create a compute instance from the most recent Oracle Linux 7.x image
resource oci_core_instance tf-oow2019-hol1512-ol7 {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "HOL1512 Oracle Linux 7"
  shape                = var.compute_instance_shape
  preserve_boot_volume = "false"

  source_details {
    source_type = "image"

    # Uncomment the line below if you want to use the latest Oracle Linux 7.x image
    # source_id   = lookup(data.oci_core_images.ImageOCID-ol7.images[0], "id")
    # In this lab, we use an old Oracle Linux 7.6 image (April 2019) to be able to apply online kernel security fixes with Ksplice
    source_id = lookup(var.image_ocid_map, var.region)
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.tf-oow2019-hol1512-public-subnet1.id
    hostname_label = "hol1512"
    # If you want to force a specific private IP, uncomment the line below and update it
    # private_ip    = "10.0.0.3"
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file_ol7)
    user_data           = base64encode(file(var.BootStrapFile_ol7))
  }
}

resource local_file sshconfig {
  content = <<EOF
Host ol7
    Hostname ${oci_core_instance.tf-oow2019-hol1512-ol7.public_ip}
    User opc
    IdentityFile ${var.ssh_private_key_file_ol7}
    #proxycommand corkscrew <proxy-host> <proxy-port> %h %p
EOF


  filename = "sshcfg"
}

# ------ Display the complete ssh command needed to connect to the instance
output "Connection" {
  value = <<EOF


  ---- Using ssh command with all parameters
  ssh -i ${var.ssh_private_key_file_ol7} opc@${oci_core_instance.tf-oow2019-hol1512-ol7.public_ip}

  ---- OR using the ssh alias contained in the sshcfg file (created in the local directory)
  ssh -F sshcfg ol7

========== Web server URL = http://${oci_core_instance.tf-oow2019-hol1512-ol7.public_ip}


EOF

}
