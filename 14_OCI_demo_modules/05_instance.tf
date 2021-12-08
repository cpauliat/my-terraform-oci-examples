# --------- Call module instance to create a compute instance using the VCN created before
module instance1 {
  source = "./module_instance"

  # ---- Input variables
  compartment_ocid    = var.g_compartment_ocid
  AD_name             = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")
  vcn_ocid            = module.vcn1.vcn_ocid
  subnet_ocid         = module.vcn1.subnet1_ocid
  shape               = "VM.Standard2.1"
  image_ocid          = lookup(data.oci_core_images.ImageOCID-ol7.images[0], "id")
  vm_name             = "tf-demo14-vm1"
  hostname            = "demo14"
  ssh_public_key_file = var.g_ssh_public_key_file
}

output Instance {
  value = <<EOF


  ---- You can SSH directly to the compute instance by typing the following ssh command
  ssh -i ${var.g_ssh_private_key_file} opc@${module.instance1.public_ip}

  ---- Alternatively, you can add the following lines to your file $HOME/.ssh/config and then just run "ssh d14ol7"

  Host d14ol7
          Hostname ${module.instance1.public_ip}
          User opc
          IdentityFile ${var.g_ssh_private_key_file}


EOF
}
