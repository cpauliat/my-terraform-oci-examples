# ------ Create a new VCN
resource oci_core_vcn tf-demo46-vcn {
  cidr_blocks    = [ var.cidr_vcn ]
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo46-vcn"
  dns_label      = "demo46"
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway tf-demo46-ig {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo46-internet-gateway"
  vcn_id         = oci_core_vcn.tf-demo46-vcn.id
}

# ------ Create a new Route Table
resource oci_core_route_table tf-demo46-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo46-vcn.id
  display_name   = "tf-demo46-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.tf-demo46-ig.id
    description       = "single route rule to Internet gateway for all traffic"
  }
}

# ------ Create a new security list to be used in the new subnet
resource oci_core_security_list tf-demo46-subnet1-sl {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo46-subnet1-security-list"
  vcn_id         = oci_core_vcn.tf-demo46-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outgoing traffic"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.cidr_vcn
  }

  dynamic "ingress_security_rules" {
    for_each = var.authorized_ips
    content {
      protocol    = "6" # tcp
      source      = ingress_security_rules.value["ip"]
      description = "Allow SSH from ${ingress_security_rules.value["description"]}"
      tcp_options {
        min = 22 
        max = 22
      }
    }
  }

  dynamic "ingress_security_rules" {
    for_each = var.authorized_ips
    content {
    protocol    = "1" # icmp
      source      = ingress_security_rules.value["ip"]
      description = "Needed for MTU from ${ingress_security_rules.value["description"]}"
      icmp_options {
        type = 3
        code = 4
      }
    }
  }
}

# ------ Create a regional public subnet 
resource oci_core_subnet tf-demo46-public-subnet1 {
  cidr_block          = var.cidr_subnet1
  display_name        = "tf-demo46-public-subnet1"
  dns_label           = "subnet1"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf-demo46-vcn.id
  route_table_id      = oci_core_route_table.tf-demo46-rt.id
  security_list_ids   = [oci_core_security_list.tf-demo46-subnet1-sl.id]
  dhcp_options_id     = oci_core_vcn.tf-demo46-vcn.default_dhcp_options_id
}

