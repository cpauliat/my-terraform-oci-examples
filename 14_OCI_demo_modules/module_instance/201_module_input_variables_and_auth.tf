# -------- Input variables for the module

# -- mandatory
variable "compartment_ocid" {}

variable "AD_name" {}
variable "vcn_ocid" {}
variable "subnet_ocid" {}
variable "shape" {}
variable "image_ocid" {}
variable "vm_name" {}
variable "ssh_public_key_file" {}
variable "hostname" {}

# -- optional
variable "assign_public_ip" { default = "true" }
