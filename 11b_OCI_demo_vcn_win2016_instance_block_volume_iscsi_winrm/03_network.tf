# -------- get the list of available ADs
data oci_identity_availability_domains ADs {
  compartment_id = var.tenancy_ocid
}

# ------ Create a new VCN
resource oci_core_vcn tf-demo11b-vcn {
  cidr_blocks    = [ var.cidr_vcn ]
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo11b-vcn"
  dns_label      = "demo11b"
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway tf-demo11b-ig {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo11b-internet-gateway"
  vcn_id         = oci_core_vcn.tf-demo11b-vcn.id
}

# ------ Create a new Route Table
resource oci_core_route_table tf-demo11b-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo11b-vcn.id
  display_name   = "tf-demo11b-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.tf-demo11b-ig.id
    description       = "single route rule to Internet gateway for all traffic"
  }
}

# ------ Create a new security list to be used in the new subnet
resource oci_core_security_list tf-demo11b-subnet1-sl {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo11b-subnet1-security-list"
  vcn_id         = oci_core_vcn.tf-demo11b-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outgoing traffic"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.cidr_vcn
  }
  ingress_security_rules {
    protocol = "6" # tcp
    source   = var.authorized_ips
    description = "Allow RDP access to Windows instance from authorized public IP address(es)"
    tcp_options {
      min = 3389 
      max = 3389
    }
  }
  ingress_security_rules {
    protocol    = "6" # tcp
    source      = var.authorized_ips
    description = "Allow WinRM thru HTTPS from authorized public IP address(es)"
    tcp_options {
      min = 5986 
      max = 5986
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

# ------ Create a regional public subnet in the new VCN
resource oci_core_subnet tf-demo11b-public-subnet1 {
  cidr_block          = var.cidr_subnet1
  display_name        = "tf-demo11b-public-subnet1"
  dns_label           = "subnet1"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf-demo11b-vcn.id
  route_table_id      = oci_core_route_table.tf-demo11b-rt.id
  security_list_ids   = [oci_core_security_list.tf-demo11b-subnet1-sl.id]
  dhcp_options_id     = oci_core_vcn.tf-demo11b-vcn.default_dhcp_options_id
}

