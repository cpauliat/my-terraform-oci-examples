# ------ Create a new VCN
resource oci_core_vcn demo39t1-vcn {
  provider       = oci.tenant1
  cidr_blocks    = [ var.tenant1_cidr_vcn ]
  compartment_id = var.tenant1_compartment_ocid
  display_name   = "demo39t1-vcn"
  dns_label      = "demo39t1"
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway demo39t1-ig {
  provider       = oci.tenant1
  compartment_id = var.tenant1_compartment_ocid
  display_name   = "demo39t1-internet-gateway"
  vcn_id         = oci_core_vcn.demo39t1-vcn.id
}

# ------ Create a new Route Table for TEST subnet
resource oci_core_route_table demo39t1-subnet-test-rt {
  provider       = oci.tenant1
  compartment_id = var.tenant1_compartment_ocid
  vcn_id         = oci_core_vcn.demo39t1-vcn.id
  display_name   = "demo39t1-test-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.demo39t1-ig.id
    description       = "Default route rule to Internet gateway"
  }

  route_rules {
    destination       = var.tenant2_cidr_vcn
    network_entity_id = oci_core_drg.demo39t1-drg.id
    description       = "Route rule to remote VCN thru DRP/IPsec"
  }
}

# ------ Create a new security list for TEST subnet
resource oci_core_security_list demo39t1-subnet-test-sl {
  provider       = oci.tenant1
  compartment_id = var.tenant1_compartment_ocid
  display_name   = "demo39t1-test-sl"
  vcn_id         = oci_core_vcn.demo39t1-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outgoing traffic"
  }

  ingress_security_rules {
    protocol    = "all"
    source      = var.tenant1_cidr_vcn
    description = "Allow all incoming traffic from local VCN"
  }

  ingress_security_rules {
    protocol    = "all"
    source      = var.tenant2_cidr_vcn
    description = "Allow all incoming traffic from VCN in remote tenant"
  }

  ingress_security_rules {
    protocol    = "6" # tcp
    source      = var.tenant1_authorized_ips
    description = "Allow SSH access to Linux instance from authorized public IP address(es)"
    tcp_options {
      min = 22 
      max = 22
    }
  }
  
  ingress_security_rules {
    protocol    = "1" # icmp
    source      = var.tenant1_authorized_ips
    description = "Needed for MTU. See https://docs.cloud.oracle.com/iaas/Content/Network/Troubleshoot/connectionhang.htm?Highlight=MTU#Path"
    icmp_options {
      type = 3
      code = 4
    }
  }
}

# ------ Create a regional public subnet for TEST instance(s)
resource oci_core_subnet demo39t1-public-subnet-test {
  provider            = oci.tenant1
  cidr_block          = var.tenant1_cidr_subnet_test
  display_name        = "demo39t1-test"
  dns_label           = "test"
  compartment_id      = var.tenant1_compartment_ocid
  vcn_id              = oci_core_vcn.demo39t1-vcn.id
  route_table_id      = oci_core_route_table.demo39t1-subnet-test-rt.id
  security_list_ids   = [oci_core_security_list.demo39t1-subnet-test-sl.id]
  dhcp_options_id     = oci_core_vcn.demo39t1-vcn.default_dhcp_options_id
}

# ------ Create a Dynamic Routing Gateway (DRG) in the new VCN and attach it to the VCN
resource oci_core_drg demo39t1-drg {
  provider       = oci.tenant1
  compartment_id = var.tenant1_compartment_ocid
  display_name   = "demo39t1-drg"
}

resource oci_core_drg_attachment demo39t1-drg {
  provider = oci.tenant1
  drg_id   = oci_core_drg.demo39t1-drg.id
  vcn_id   = oci_core_vcn.demo39t1-vcn.id
}