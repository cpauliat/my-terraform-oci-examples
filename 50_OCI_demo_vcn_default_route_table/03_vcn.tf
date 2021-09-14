# ------ Create a new VCN
resource oci_core_vcn tf-demo50-vcn {
  cidr_blocks    = var.cidr_vcn
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo50-vcn"
  dns_label      = "demo50"
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway tf-demo50-ig {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo50-internet-gateway"
  vcn_id         = oci_core_vcn.tf-demo50-vcn.id
}

# ------ Add route rules to default route table
resource oci_core_default_route_table tf-demo50-default-rt {
  manage_default_resource_id = oci_core_vcn.tf-demo50-vcn.default_route_table_id

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.tf-demo50-ig.id
    description       = "single route rule to Internet gateway for all traffic"
  }
}

# ------ Add security rules to default security list
resource oci_core_default_security_list tf-demo50-default-sl {
  manage_default_resource_id = oci_core_vcn.tf-demo50-vcn.default_security_list_id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outgoing traffic"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.cidr_vcn[0]
  }
  
  ingress_security_rules {
    protocol    = "6" # tcp
    source      = var.authorized_ips
    description = "Allow SSH access to Linux instance from authorized public IP address(es)"
    tcp_options {
      min = 22 
      max = 22
    }
  }
  ingress_security_rules {
    protocol    = "1" # icmp
    source      = var.authorized_ips
    description = "Needed for MTU. See https://docs.cloud.oracle.com/iaas/Content/Network/Troubleshoot/connectionhang.htm?Highlight=MTU#Path"
    icmp_options {
      type = 3
      code = 4
    }
  }
}

# ------ Create a regional public subnet 
resource oci_core_subnet tf-demo50-public-subnet1 {
  cidr_block          = var.cidr_subnet1
  display_name        = "tf-demo50-public-subnet1"
  dns_label           = "subnet1"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf-demo50-vcn.id
  route_table_id      = oci_core_vcn.tf-demo50-vcn.default_route_table_id
  security_list_ids   = [ oci_core_vcn.tf-demo50-vcn.default_security_list_id ]
  dhcp_options_id     = oci_core_vcn.tf-demo50-vcn.default_dhcp_options_id
}

