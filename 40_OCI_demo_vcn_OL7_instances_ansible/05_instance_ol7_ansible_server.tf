# ------ Create a compute instance from the most recent Oracle Linux 7.x image
resource oci_core_instance tf-demo40-ansible {
  depends_on = [ oci_core_instance.tf-demo40-host1 ]

  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "tf-demo40-ansible"
  shape                = "VM.Standard.E2.1"
  preserve_boot_volume = "false"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.tf-demo40-public-subnet1.id
    hostname_label = "d40ansible"
  }

  metadata = {
    ssh_authorized_keys  = file(var.ssh_public_key_file_ansible)
    user_data            = base64encode(file(var.BootStrapFile_ansible))
    myarg_host1_hostname = var.host1_hostname
  }
}

# ------ Copy Ansible playbooks to Ansible server
resource null_resource tf-demo40-ansible {
  depends_on = [ oci_core_instance.tf-demo40-host1 ]

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "10m"
      host        = oci_core_instance.tf-demo40-ansible.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file_ansible)
    }
    source      = "ansible_playbook.yml"
    destination = "/home/opc/ansible_playbook.yml"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "10m"
      host        = oci_core_instance.tf-demo40-ansible.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file_ansible)
    }
    source      = var.ssh_private_key_file_host1
    destination = "/home/opc/.ssh/sshkey_host1"
  }
}

# ------ Display the complete ssh command needed to connect to the instance
output Instance_ANSIBLE {
  value = <<EOF


  ---- You can SSH directly to the ANSIBLE instance by typing the following ssh command
  ssh -i ${var.ssh_private_key_file_ansible} opc@${oci_core_instance.tf-demo40-ansible.public_ip}

  ---- Alternatively, you can add the following lines to your file $HOME/.ssh/config and then just run "ssh d40ansible"

  Host d40ansible
          Hostname ${oci_core_instance.tf-demo40-ansible.public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_ansible}

  
EOF

}

