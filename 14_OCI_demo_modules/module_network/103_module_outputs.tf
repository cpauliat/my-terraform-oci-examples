# ------ MODULE outputs

output vcn_ocid {
  value = oci_core_virtual_network.tf-vcn.id
}

output subnet1_ocid {
  value = oci_core_subnet.tf-public-subnet1.id
}
