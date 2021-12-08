# -------- Input variables for the module

# -- mandatory
variable "compartment_ocid" {}
variable "authorized_ips" {}
variable "name_vcn" {}

# -- optional
variable "cidr_vcn"          { default = "10.0.0.0/16" }
variable "cidr_subnet1"      { default = "10.0.1.0/24" }
variable "name_subnet1"      { default = "subnet1" }
variable "dns_label_vcn"     { default = "vcn" }
variable "dns_label_subnet1" { default = "subnet1" }
