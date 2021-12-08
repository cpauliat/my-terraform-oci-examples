# ------ Create a new VCN
resource oci_core_virtual_network tf-vcn {
  cidr_blocks    = [ var.cidr_vcn ]
  compartment_id = var.compartment_ocid
  display_name   = var.name_vcn
  dns_label      = var.dns_label_vcn
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway tf-ig {
  compartment_id = var.compartment_ocid
  display_name   = "tf-internet-gateway"
  vcn_id         = oci_core_virtual_network.tf-vcn.id
}

# ------ Create a new Route Table
resource oci_core_route_table tf-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.tf-vcn.id
  display_name   = "tf-route-table"

  route_rules {
    cidr_block        = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.tf-ig.id
  }
}

# ------ Create a new security list to be used in the new subnet 1
resource oci_core_security_list tf-subnet1-sl {
  compartment_id = var.compartment_ocid
  display_name   = "tf-subnet1-security-list"
  vcn_id         = oci_core_virtual_network.tf-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6"               # tcp
    source   = var.cidr_vcn
  }

  ingress_security_rules {
    protocol = "6"                     # tcp
    source   = var.authorized_ips

    tcp_options {
      min = 22
      max = 22
    }
  }
}

# ------ Create a public regional subnet 1 in the new VCN
resource oci_core_subnet tf-public-subnet1 {
  cidr_block          = var.cidr_subnet1
  display_name        = var.name_subnet1
  dns_label           = var.dns_label_subnet1
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_virtual_network.tf-vcn.id
  route_table_id      = oci_core_route_table.tf-rt.id
  security_list_ids   = [ oci_core_security_list.tf-subnet1-sl.id ]
  dhcp_options_id     = oci_core_virtual_network.tf-vcn.default_dhcp_options_id
}
