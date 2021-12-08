# -------- get the list of available ADs
data oci_identity_availability_domains ADs {
  compartment_id = var.tenancy_ocid
}

# ------ Create a new VCN
resource oci_core_vcn tf-demo05b-vcn {
  cidr_blocks    = [ var.cidr_vcn ]
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo05b-vcn"
  dns_label      = var.dns_vcn
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway tf-demo05b-ig {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo05b-internet-gateway"
  vcn_id         = oci_core_vcn.tf-demo05b-vcn.id
}

# ------ Create a new Route Table (common to both subnets)
resource oci_core_route_table tf-demo05b-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo05b-vcn.id
  display_name   = "tf-demo05b-route-table"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.tf-demo05b-ig.id
  }
}

# ------ Create a new security list to be used in the new subnet public1
resource oci_core_security_list tf-demo05b-subnet1-sl {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo05b-subnet1-security-list"
  vcn_id         = oci_core_vcn.tf-demo05b-vcn.id
  
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.cidr_vcn
    description = "Allow all traffic within VCN"
  }
  
  ingress_security_rules {
    protocol = "6" # tcp
    source   = var.authorized_ips
    description = "Allow SSH access from authorised public IP"
    tcp_options {
      min = 22
      max = 22
    }
  }
  ingress_security_rules {
    protocol = "6" # tcp
    source   = var.authorized_ips
    description = "Allow SQLNET access from authorised public IP"
    tcp_options {
      min = 1521
      max = 1521
    }
  }
}

# ------ Create a regional public subnet in the new VCN
resource oci_core_subnet tf-demo05b-public-subnet1 {
  cidr_block          = var.cidr_subnet1
  display_name        = "tf-demo05b-public-subnet1"
  dns_label           = var.dns_subnet1
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf-demo05b-vcn.id
  route_table_id      = oci_core_route_table.tf-demo05b-rt.id
  security_list_ids   = [oci_core_security_list.tf-demo05b-subnet1-sl.id]
  dhcp_options_id     = oci_core_vcn.tf-demo05b-vcn.default_dhcp_options_id
}
