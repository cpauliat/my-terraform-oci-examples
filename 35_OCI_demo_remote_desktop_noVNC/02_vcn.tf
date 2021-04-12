# -------- get the list of available ADs
data oci_identity_availability_domains ADs {
  compartment_id = var.tenancy_ocid
}

# ------ Create a new VCN
resource oci_core_vcn demo35-vcn {
  cidr_block     = var.cidr_vcn
  compartment_id = var.compartment_ocid
  display_name   = "demo35-vcn"
  dns_label      = "demo35"
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway demo35-ig {
  compartment_id = var.compartment_ocid
  display_name   = "internet gateway"
  vcn_id         = oci_core_vcn.demo35-vcn.id
}

# ------ Create a new Route Table
resource oci_core_route_table demo35-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.demo35-vcn.id
  display_name   = "demo35 route table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.demo35-ig.id
  }
}

# ------ Create a new security list 
resource oci_core_security_list demo35-sl {
  compartment_id = var.compartment_ocid
  display_name   = "demo35 subnet security list"
  vcn_id         = oci_core_vcn.demo35-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.cidr_vcn
  }
}

# ------ Create a public regional subnet 
resource oci_core_subnet demo35-subnet1 {
  cidr_block          = var.cidr_subnet1
  display_name        = "subnet1"
  dns_label           = "subnet1"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.demo35-vcn.id
  route_table_id      = oci_core_route_table.demo35-rt.id
  security_list_ids   = [oci_core_security_list.demo35-sl.id]
  dhcp_options_id     = oci_core_vcn.demo35-vcn.default_dhcp_options_id
}
