# -------- get the list of available ADs
data oci_identity_availability_domains ADs {
  compartment_id = var.tenancy_ocid
}

# ------ Create a new VCN
resource oci_core_vcn tf-demo04-vcn {
  cidr_blocks    = [ var.cidr_vcn ]
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo04-vcn"
  dns_label      = "demo04"
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway tf-demo04-ig {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo04-internet-gateway"
  vcn_id         = oci_core_vcn.tf-demo04-vcn.id
}

# ------ Create a new Route Table
resource oci_core_route_table tf-demo04-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo04-vcn.id
  display_name   = "tf-demo04-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.tf-demo04-ig.id
  }
}

# ------ Create a new empty security list to be used in the new subnet instead of default security list
resource oci_core_security_list tf-demo04-subnet1-sl {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo04-subnet1-security-list"
  vcn_id         = oci_core_vcn.tf-demo04-vcn.id
}

# ------ Create a public subnet 1 in AD1 in the new VCN
resource oci_core_subnet tf-demo04-public-subnet1 {
# uncomment the following line to create an AD specific subnet
# availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  cidr_block          = var.cidr_subnet1
  display_name        = "tf-demo04-public-subnet1"
  dns_label           = "subnet1"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf-demo04-vcn.id
  route_table_id      = oci_core_route_table.tf-demo04-rt.id
  security_list_ids   = [oci_core_security_list.tf-demo04-subnet1-sl.id]
  dhcp_options_id     = oci_core_vcn.tf-demo04-vcn.default_dhcp_options_id
}

