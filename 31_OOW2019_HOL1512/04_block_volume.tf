# ------ Create a block volume
resource "oci_core_volume" "tf-oow2019-hol1512-vol1" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = "HOL1512 volume1"
  size_in_gbs         = "60"
}

# ------ Attach the new block volume to the ol7 compute instance after it is created
resource "oci_core_volume_attachment" "tf-oow2019-hol1512-vol1" {
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.tf-oow2019-hol1512-ol7.id
  volume_id       = oci_core_volume.tf-oow2019-hol1512-vol1.id
  device          = "/dev/oracleoci/oraclevdb"
}
