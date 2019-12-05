# --------- Get the OCID for the most recent Oracle Linux 7.x image
data "oci_core_images" "OLImageOCID-ol7" {
  compartment_id           = "${var.g_compartment_ocid}"
  operating_system         = "Oracle Linux"
  operating_system_version = "7.7"

  # filter to avoid Oracle Linux 7.x images for GPU
  filter {
    name   = "display_name"
    values = ["^.*Oracle-Linux-7.7-[^G].*$"]
    regex  = true
  }
}

# --------- Call module instance to create a compute instance using the VCN created before
module "instance1" {
  source = "./module_instance"

  # ---- Input variables
  tenancy_ocid        = var.g_tenancy_ocid
  user_ocid           = var.g_user_ocid
  fingerprint         = var.g_fingerprint
  private_key_path    = var.g_private_key_path
  compartment_ocid    = var.g_compartment_ocid
  region              = var.g_region

  AD                  = "1"
  vcn_ocid            = module.vcn1.vcn_ocid
  subnet_ocid         = module.vcn1.subnet1_ocid
  shape               = "VM.Standard2.1"
  image_ocid          = lookup(data.oci_core_images.OLImageOCID-ol7.images[0], "id")
  vm_name             = "tf-demo14-vm1"
  hostname            = "demo14"
  ssh_public_key_file = var.g_ssh_public_key_file
}

output "Instance" {
  value = <<EOF


  ---- You can SSH directly to the compute instance by typing the following ssh command
  ssh -i ${var.g_ssh_private_key_file} opc@${module.instance1.public_ip}

  ---- Alternatively, you can add the following lines to your file $HOME/.ssh/config and then just run "ssh ol7"

  Host ol7
          Hostname ${module.instance1.public_ip}
          User opc
          IdentityFile ${var.g_ssh_private_key_file}


EOF
}