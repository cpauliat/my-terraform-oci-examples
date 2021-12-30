# ------ Create a new VCN
resource oci_core_vcn demo39t2-vcn {
  provider       = oci.tenant2
  cidr_blocks    = [ var.tenant2_cidr_vcn ]
  compartment_id = var.tenant2_compartment_ocid
  display_name   = "demo39t2-vcn"
  dns_label      = "demo39t2"
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway demo39t2-ig {
  provider       = oci.tenant2
  compartment_id = var.tenant2_compartment_ocid
  display_name   = "demo39t2-internet-gateway"
  vcn_id         = oci_core_vcn.demo39t2-vcn.id
}

# ========== Resources for LIBRESWAN subnet

# ------ Create a new Route Table for LIBRESWAN subnet
resource oci_core_route_table demo39t2-subnet-libreswan-rt {
  provider       = oci.tenant2
  compartment_id = var.tenant2_compartment_ocid
  vcn_id         = oci_core_vcn.demo39t2-vcn.id
  display_name   = "demo39t2-libreswan-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.demo39t2-ig.id
    description       = "Default route rule to Internet gateway"
  }
}

# ------ Create a new security list for LIBRESWAN subnet
resource oci_core_security_list demo39t2-subnet-libreswan-sl {
  provider       = oci.tenant2
  compartment_id = var.tenant2_compartment_ocid
  display_name   = "demo39t2-libreswan-sl"
  vcn_id         = oci_core_vcn.demo39t2-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outgoing traffic"
  }

  ingress_security_rules {
    protocol    = "all"
    source      = var.tenant2_cidr_vcn
    description = "Allow all incoming traffic from local VCN"
  }

  ingress_security_rules {
    protocol    = "all"
    source      = var.tenant1_cidr_vcn
    description = "Allow all incoming traffic from VCN in remote tenant"
  }

  ingress_security_rules {
    protocol    = "6" # tcp
    source      = var.tenant2_authorized_ips
    description = "Allow SSH access to Linux instance from authorized public IP address(es)"
    tcp_options {
      min = 22 
      max = 22
    }
  }

  ingress_security_rules {
    protocol    = "1" # icmp
    source      = var.tenant2_authorized_ips
    description = "Needed for MTU. See https://docs.cloud.oracle.com/iaas/Content/Network/Troubleshoot/connectionhang.htm?Highlight=MTU#Path"
    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    protocol    = "17" # udp
    source      = "0.0.0.0/0"
    description = "Allow IPSEC VPN access"
    udp_options {
      min = 4500 
      max = 4500
    }
  }

  ingress_security_rules {
    protocol    = "17" # udp
    source      = "0.0.0.0/0"
    description = "Allow IPSEC VPN access"
    udp_options {
      min = 500 
      max = 500
    }
  }
}

# ------ Create a regional public subnet for LIBRESWAN instance
resource oci_core_subnet demo39t2-public-subnet-libreswan {
  provider            = oci.tenant2
  cidr_block          = var.tenant2_cidr_subnet_libreswan
  display_name        = "demo39t2-libreswan"
  dns_label           = "libreswan"
  compartment_id      = var.tenant2_compartment_ocid
  vcn_id              = oci_core_vcn.demo39t2-vcn.id
  route_table_id      = oci_core_route_table.demo39t2-subnet-libreswan-rt.id
  security_list_ids   = [ oci_core_security_list.demo39t2-subnet-libreswan-sl.id ]
  dhcp_options_id     = oci_core_vcn.demo39t2-vcn.default_dhcp_options_id
}

# ========== Resources for TEST subnet

# ------ get the OCID of the private IP for LIBRESWAN instance in tenant 2
data oci_core_private_ips demo39t2-libreswan {
    provider   = oci.tenant2 
    ip_address = oci_core_instance.demo39t2-libreswan.private_ip
    subnet_id  = oci_core_subnet.demo39t2-public-subnet-libreswan.id
}

# ------ Create a new Route Table for TEST subnet
resource oci_core_route_table demo39t2-subnet-test-rt {
  provider       = oci.tenant2
  compartment_id = var.tenant2_compartment_ocid
  vcn_id         = oci_core_vcn.demo39t2-vcn.id
  display_name   = "demo39t2-test-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.demo39t2-ig.id
    description       = "Default route rule to Internet gateway"
  }

  route_rules {
    destination       = var.tenant1_cidr_vcn
    network_entity_id = lookup(data.oci_core_private_ips.demo39t2-libreswan.private_ips[0],"id")
    description       = "Route rule to remote VCN thru DRP/IPsec via LIBRESWAN compute instance"
  }
}

# ------ Create a new security list for TEST subnet
resource oci_core_security_list demo39t2-subnet-test-sl {
  provider       = oci.tenant2
  compartment_id = var.tenant2_compartment_ocid
  display_name   = "demo39t2-test-sl"
  vcn_id         = oci_core_vcn.demo39t2-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outgoing traffic"
  }

  ingress_security_rules {
    protocol    = "all"
    source      = var.tenant2_cidr_vcn
    description = "Allow all incoming traffic from local VCN"
  }

  ingress_security_rules {
    protocol    = "all"
    source      = var.tenant1_cidr_vcn
    description = "Allow all incoming traffic from VCN in remote tenant"
  }

  ingress_security_rules {
    protocol    = "6" # tcp
    source      = var.tenant2_authorized_ips
    description = "Allow SSH access to Linux instance from authorized public IP address(es)"
    tcp_options {
      min = 22 
      max = 22
    }
  }

  ingress_security_rules {
    protocol    = "1" # icmp
    source      = var.tenant2_authorized_ips
    description = "Needed for MTU. See https://docs.cloud.oracle.com/iaas/Content/Network/Troubleshoot/connectionhang.htm?Highlight=MTU#Path"
    icmp_options {
      type = 3
      code = 4
    }
  }
}

# ------ Create a regional public subnet for TEST instance(s)
resource oci_core_subnet demo39t2-public-subnet-test {
  provider            = oci.tenant2
  cidr_block          = var.tenant2_cidr_subnet_test
  display_name        = "demo39t2-test"
  dns_label           = "test"
  compartment_id      = var.tenant2_compartment_ocid
  vcn_id              = oci_core_vcn.demo39t2-vcn.id
  route_table_id      = oci_core_route_table.demo39t2-subnet-test-rt.id
  security_list_ids   = [ oci_core_security_list.demo39t2-subnet-test-sl.id ]
  dhcp_options_id     = oci_core_vcn.demo39t2-vcn.default_dhcp_options_id
}

# # ----------
# data oci_core_private_ips test_private_ips_by_subnet {
#   subnet_id = oci_core_subnet.demo39t2-public-subnet-libreswan.id
# }

# output test {
#   value = data.oci_core_private_ips.test_private_ips_by_subnet
# }