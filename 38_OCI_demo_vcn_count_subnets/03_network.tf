# -------- get the list of available ADs
data oci_identity_availability_domains ADs {
  compartment_id = var.tenancy_ocid
}

# ------ Create a new VCN
resource oci_core_vcn tf-demo38-vcn {
  cidr_blocks    = [ var.cidr_vcn ]
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo38-vcn"
  dns_label      = "tfdemovcn"
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway tf-demo38-ig {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo38-internet-gateway"
  vcn_id         = oci_core_vcn.tf-demo38-vcn.id
}

# ------ Create a new Route Table
resource oci_core_route_table tf-demo38-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo38-vcn.id
  display_name   = "tf-demo38-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.tf-demo38-ig.id
  }
}

# ------ Create a new security list to be used in the new subnet
resource oci_core_security_list tf-demo38-subnet1-sl {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo38-subnet1-security-list"
  vcn_id         = oci_core_vcn.tf-demo38-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.cidr_vcn
  }
  ingress_security_rules {
    protocol = "6" # tcp
    source   = "0.0.0.0/0"

    tcp_options {
      min = 22 # to allow SSH acccess to Linux instance
      max = 22
    }
  }
  # needed. See https://docs.cloud.oracle.com/iaas/Content/Network/Troubleshoot/connectionhang.htm?Highlight=MTU#Path
  ingress_security_rules {
    protocol = "1" # icmp
    source   = "0.0.0.0/0"

    icmp_options {
      type = 3
      code = 4
    }
  }
}

# ------ Create several regional public subnets
resource oci_core_subnet tf-demo38-subnet {
  count               = var.nb_subnets
  cidr_block          = var.subnets_cidr[count.index]
  display_name        = var.subnets_name[count.index]
  dns_label           = var.subnets_dnslabel[count.index]
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf-demo38-vcn.id
  route_table_id      = oci_core_route_table.tf-demo38-rt.id
  security_list_ids   = [oci_core_security_list.tf-demo38-subnet1-sl.id]
  dhcp_options_id     = oci_core_vcn.tf-demo38-vcn.default_dhcp_options_id
}
