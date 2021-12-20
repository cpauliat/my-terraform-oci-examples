# ------ Create a new VCN
resource oci_core_vcn tf-demo02-vcn {
  cidr_blocks    = [ var.cidr_vcn ]
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo02-vcn"
  dns_label      = "demo02"
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway tf-demo02-ig {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo02-internet-gateway"
  vcn_id         = oci_core_vcn.tf-demo02-vcn.id
}

# ------ Create a new Route Table
resource oci_core_route_table tf-demo02-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo02-vcn.id
  display_name   = "tf-demo02-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.tf-demo02-ig.id
    description       = "single route rule to Internet gateway for all traffic"
  }
}

# ------ Create a new security list to be used in the new subnet
resource oci_core_security_list tf-demo02-subnet1-sl {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo02-subnet1-security-list"
  vcn_id         = oci_core_vcn.tf-demo02-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outgoing traffic"
  }

  ingress_security_rules {
    protocol    = "6" # tcp
    source      = var.cidr_vcn
    description = "Allow communication between all VNICs inside the VCN"
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
  # needed. See https://docs.cloud.oracle.com/iaas/Content/Network/Troubleshoot/connectionhang.htm?Highlight=MTU#Path
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

# ------ Create a public subnet (AD specific) in the new VCN
resource oci_core_subnet tf-demo02-public-subnet1 {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  cidr_block          = var.cidr_subnet1
  display_name        = "tf-demo02-public-subnet1"
  dns_label           = "subnet1"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf-demo02-vcn.id
  route_table_id      = oci_core_route_table.tf-demo02-rt.id
  security_list_ids   = [oci_core_security_list.tf-demo02-subnet1-sl.id]
  dhcp_options_id     = oci_core_vcn.tf-demo02-vcn.default_dhcp_options_id
}

