# ------ Create a new VCN
resource oci_core_vcn tf-demo27-vcn {
  cidr_blocks    = [ var.cidr_vcn ]
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo27-vcn"
  dns_label      = "tfdemovcn"
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway tf-demo27-ig {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo27-internet-gateway"
  vcn_id         = oci_core_vcn.tf-demo27-vcn.id
}

# ------ Create a new Route Table
resource oci_core_route_table tf-demo27-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo27-vcn.id
  display_name   = "tf-demo27-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.tf-demo27-ig.id
  }
}

# ------ Create a new security list to be used in the new subnet
resource oci_core_security_list tf-demo27-subnet1-sl {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo27-subnet1-security-list"
  vcn_id         = oci_core_vcn.tf-demo27-vcn.id

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
      min = 22 # to allow SSH acccess to Linux instance
      max = 22
    }
  }
  ingress_security_rules {
    protocol = "6" # tcp
    source   = "0.0.0.0/0"

    tcp_options {
      min = 80 # to allow access to Web Server with HTTP
      max = 80
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

# ------ Create a regional public subnet 
resource oci_core_subnet tf-demo27-public-subnet1 {
  cidr_block          = var.cidr_subnet1
  display_name        = "tf-demo27-public-subnet1"
  dns_label           = "subnet1"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf-demo27-vcn.id
  route_table_id      = oci_core_route_table.tf-demo27-rt.id
  security_list_ids   = [oci_core_security_list.tf-demo27-subnet1-sl.id]
  dhcp_options_id     = oci_core_vcn.tf-demo27-vcn.default_dhcp_options_id
}

