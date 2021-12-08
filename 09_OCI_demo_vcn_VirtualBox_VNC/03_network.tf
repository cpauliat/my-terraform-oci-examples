# ------ Create a new VCN
resource oci_core_vcn tf-demo09-vbox-vcn {
  cidr_blocks    = [ var.cidr_vcn ]
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo09-vbox-vcn"
  dns_label      = "tfdemo09vcn"
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway tf-demo09-vbox-ig {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo09-vbox-internet-gateway"
  vcn_id         = oci_core_vcn.tf-demo09-vbox-vcn.id
}

# ------ Create a new Route Table
resource oci_core_route_table tf-demo09-vbox-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo09-vbox-vcn.id
  display_name   = "tf-demo09-vbox-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.tf-demo09-vbox-ig.id
  }
}

# ------ Create a new security list to be used in the new subnet
resource oci_core_security_list tf-demo09-vbox-subnet1-sl {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo09-vbox-subnet1-security-list"
  vcn_id         = oci_core_vcn.tf-demo09-vbox-vcn.id

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
    source   = var.authorized_ips

    tcp_options {
      min = 22
      max = 22
    }
  }
  # needed. See https://docs.cloud.oracle.com/iaas/Content/Network/Troubleshoot/connectionhang.htm?Highlight=MTU#Path
  ingress_security_rules {
    protocol = "1" # icmp
    source   = var.authorized_ips

    icmp_options {
      type = 3
      code = 4
    }
  }
}

# ------ Create a regional public subnet in the new VCN
resource oci_core_subnet tf-demo09-vbox-public-subnet1 {
  cidr_block          = var.cidr_subnet1
  display_name        = "tf-demo09-vbox-public-subnet-1"
  dns_label           = "subnet1"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf-demo09-vbox-vcn.id
  route_table_id      = oci_core_route_table.tf-demo09-vbox-rt.id
  security_list_ids   = [oci_core_security_list.tf-demo09-vbox-subnet1-sl.id]
  dhcp_options_id     = oci_core_vcn.tf-demo09-vbox-vcn.default_dhcp_options_id
}
