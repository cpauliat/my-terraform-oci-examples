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

# ------ Create several compute instances from the most recent Oracle Linux 7.x image
resource "oci_core_instance" "tf-demo06-ol7" {
  count                = var.number_of_instances

  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "tf-demo06-ol7-${count.index}"
  shape                = "VM.Standard2.1"
  preserve_boot_volume = "false"

  create_vnic_details {
    subnet_id      = oci_core_subnet.tf-demo06-public-subnet1.id
    hostname_label = "ol7-${count.index}"
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file_ol7)
    user_data           = base64encode(file(var.BootStrapFile_ol7))
  }
}

output "public_IP_adresses_of_compute_instances" {
  value = oci_core_instance.tf-demo06-ol7.*.public_ip
}

# ------ Display the complete ssh command needed to connect to the instances

output "SSH_connections" {
  value = [
    for instance in oci_core_instance.tf-demo06-ol7.*:
      "ol7-${index(oci_core_instance.tf-demo06-ol7.*, instance)}: ssh -i ${var.ssh_private_key_file_ol7} opc@${instance.public_ip}"
  ]

}

output "Instances" {
  value = <<EOF


  ---- You can SSH directly to the OL7 compute instances by typing the following ssh commands
  for ol7-0: ssh -i ${var.ssh_private_key_file_ol7} opc@${oci_core_instance.tf-demo06-ol7[0].public_ip}
  for ol7-1: ssh -i ${var.ssh_private_key_file_ol7} opc@${oci_core_instance.tf-demo06-ol7[1].public_ip}
  for ol7-2: ssh -i ${var.ssh_private_key_file_ol7} opc@${oci_core_instance.tf-demo06-ol7[2].public_ip}

  ---- Alternatively, you can add the following lines to your file $HOME/.ssh/config and then just run "ssh ol7-x"

  Host ol7-0
          Hostname ${oci_core_instance.tf-demo06-ol7[0].public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_ol7}

  Host ol7-1
          Hostname ${oci_core_instance.tf-demo06-ol7[1].public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_ol7}

  Host ol7-2
          Hostname ${oci_core_instance.tf-demo06-ol7[2].public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_ol7}

  
EOF
}
