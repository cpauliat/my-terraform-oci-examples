# ------ Create a compute instance from the most recent Windows 2016/2019 image
resource oci_core_instance tf-demo10-win201x {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "tf-demo10-win201x"
  preserve_boot_volume = "false"
  shape                = "VM.Standard2.1"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-win201x.images[0]["id"]
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.tf-demo10-public-subnet1.id
    hostname_label = "d10w201x"
  }

  metadata = {
    user_data      = base64encode(file(var.BootStrapFile_win201x))
  }
}

# ------ Display connection details
data oci_core_instance_credentials tf-demo10-win201x {
  instance_id = oci_core_instance.tf-demo10-win201x.id
}

output Instance_Win201x {
  value = <<EOF


  ---- You can RDP directly to the Win${var.os_version} instance using following parameters
  public IP = ${oci_core_instance.tf-demo10-win201x.public_ip}

  user      = ${data.oci_core_instance_credentials.tf-demo10-win201x.username}  (user with Administrator privileges)
  password  = ${data.oci_core_instance_credentials.tf-demo10-win201x.password}  (temporary password, needs to be changed on the first connection)

  OR

  user     = user01   (regular user)
  password = TH1S_1s_my_PWD

  OR

  user     = opc2   (user with Administrator privileges)
  password = TH1S_1s_my_PWD
EOF

}
