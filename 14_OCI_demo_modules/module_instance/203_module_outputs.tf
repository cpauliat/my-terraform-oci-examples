# ------ MODULE outputs
output public_ip {
  value = oci_core_instance.tf-instance.public_ip
}

output private_ip {
  value = oci_core_instance.tf-instance.private_ip
}
