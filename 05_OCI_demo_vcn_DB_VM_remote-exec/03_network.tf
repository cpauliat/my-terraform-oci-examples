# -------- get the list of available ADs
data oci_identity_availability_domains ADs {
  compartment_id = var.tenancy_ocid
}

# ------ Create a new VCN
resource oci_core_vcn tf-demo05-vcn {
  cidr_blocks    = [ var.cidr_vcn ]
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo05-vcn"
  dns_label      = var.dns_vcn
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway tf-demo05-ig {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo05-internet-gateway"
  vcn_id         = oci_core_vcn.tf-demo05-vcn.id
}

# ------ Create a new Route Table
resource oci_core_route_table tf-demo05-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo05-vcn.id
  display_name   = "tf-demo05-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.tf-demo05-ig.id
  }
}

# ------ Create a new security list to be used in the new subnet
resource oci_core_security_list tf-demo05-subnet1-sl {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo05-subnet1-security-list"
  vcn_id         = oci_core_vcn.tf-demo05-vcn.id

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

  # needed. See https://docs.cloud.oracle.com/iaas/Content/Network/Troubleshoot/connectionhang.htm?Highlight=MTU#Path
  ingress_security_rules {
    protocol = "1" # icmp
    source   = var.authorized_ips
    description = "Enable MTU negotiation for communication from authorised public IP"
    icmp_options {
      type = 3
      code = 4
    }
  }
}

# ------ Create a public subnet 1 in the new VCN
resource oci_core_subnet tf-demo05-public-subnet1 {
  cidr_block          = var.cidr_subnet1
  display_name        = "tf-demo05-public-subnet1"
  dns_label           = var.dns_subnet1
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf-demo05-vcn.id
  route_table_id      = oci_core_route_table.tf-demo05-rt.id
  security_list_ids   = [oci_core_security_list.tf-demo05-subnet1-sl.id]
  dhcp_options_id     = oci_core_vcn.tf-demo05-vcn.default_dhcp_options_id
}

