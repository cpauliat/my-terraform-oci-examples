# ------ Create a new VCN
resource oci_core_vcn tf-demo41-vcn {
  cidr_blocks    = [ var.cidr_vcn ]
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo41-vcn"
  dns_label      = "demo41"
}

# ============ Public subnet and related objects

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway tf-demo41-ig {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo41-internet-gateway"
  vcn_id         = oci_core_vcn.tf-demo41-vcn.id
}

# ------ Create a new Route Table
resource oci_core_route_table tf-demo41-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo41-vcn.id
  display_name   = "tf-demo41-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.tf-demo41-ig.id
    description       = "single route rule to Internet gateway for all traffic"
  }
}

# ------ Create a new security list to be used in the new subnet
resource oci_core_security_list tf-demo41-subnet1-sl {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo41-subnet1-security-list"
  vcn_id         = oci_core_vcn.tf-demo41-vcn.id

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
resource oci_core_subnet tf-demo41-public-subnet1 {
  cidr_block          = var.cidr_subnet1
  display_name        = "tf-demo41-subnet1-public"
  dns_label           = "subnet1"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf-demo41-vcn.id
  route_table_id      = oci_core_route_table.tf-demo41-rt.id
  security_list_ids   = [oci_core_security_list.tf-demo41-subnet1-sl.id]
  dhcp_options_id     = oci_core_vcn.tf-demo41-vcn.default_dhcp_options_id
}

# ============ Private subnet and related objects

# ------ Create a new Services Gategay
data oci_core_services services {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource oci_core_service_gateway tf-demo41-private-sgw {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo41-vcn.id
  services {
    service_id = lookup(data.oci_core_services.services.services[0], "id")
  }
  display_name   = "tf-demo41-private-sgw"
}

# ------ Create a NAT gateway
resource oci_core_nat_gateway tf-demo41-private-natgw {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo41-vcn.id
  display_name   = "tf-demo41-private-natgw"
}

# ------ Create a new Route Table
resource oci_core_route_table tf-demo41-private-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo41-vcn.id
  display_name   = "tf-demo41-private-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.tf-demo41-private-natgw.id
  }

  route_rules {
    destination       = lookup(data.oci_core_services.services.services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.tf-demo41-private-sgw.id
  }
}

# ------ Create a new security list to be used in the new subnet
resource oci_core_security_list tf-demo41-private-subnet-sl {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo41-private-subnet-seclist"
  vcn_id         = oci_core_vcn.tf-demo41-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.cidr_vcn
  }
}

# ------ Create a private regional subnet in the new VCN
resource oci_core_subnet tf-demo41-private-subnet {
  cidr_block          = var.cidr_subnet2
  display_name        = "tf-demo41-subnet2-private"
  dns_label           = "subnet2"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf-demo41-vcn.id
  route_table_id      = oci_core_route_table.tf-demo41-private-rt.id
  security_list_ids   = [oci_core_security_list.tf-demo41-private-subnet-sl.id]
  dhcp_options_id     = oci_core_vcn.tf-demo41-vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = true
}
