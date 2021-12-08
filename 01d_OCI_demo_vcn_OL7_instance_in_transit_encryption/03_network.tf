# ------ Create a new VCN
resource oci_core_vcn tf-demo01d-vcn {
  cidr_blocks    = var.cidr_vcn
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo01d-vcn"
  dns_label      = "demo01d"
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway tf-demo01d-ig {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo01d-internet-gateway"
  vcn_id         = oci_core_vcn.tf-demo01d-vcn.id
}

# ------ Create a new Route Table
resource oci_core_route_table tf-demo01d-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo01d-vcn.id
  display_name   = "tf-demo01d-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.tf-demo01d-ig.id
    description       = "single route rule to Internet gateway for all traffic"
  }
}

# ------ Create a new security list to be used in the new subnet
resource oci_core_security_list tf-demo01d-subnet1-sl {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo01d-subnet1-security-list"
  vcn_id         = oci_core_vcn.tf-demo01d-vcn.id

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
resource oci_core_subnet tf-demo01d-public-subnet1 {
# uncomment the following line to create an AD specific subnet
# availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  cidr_block          = var.cidr_subnet1
  display_name        = "tf-demo01d-public-subnet1"
  dns_label           = "subnet1"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf-demo01d-vcn.id
  route_table_id      = oci_core_route_table.tf-demo01d-rt.id
  security_list_ids   = [oci_core_security_list.tf-demo01d-subnet1-sl.id]
  dhcp_options_id     = oci_core_vcn.tf-demo01d-vcn.default_dhcp_options_id
}

