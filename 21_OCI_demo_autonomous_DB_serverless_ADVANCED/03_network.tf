# -------- get the list of available ADs
data oci_identity_availability_domains ADs {
  compartment_id = var.tenancy_ocid
}

# ------ Create a new VCN
resource oci_core_vcn tf-demo21-vcn {
  cidr_blocks    = [ var.cidr_vcn ]
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo21-vcn"
  dns_label      = "demo21"
}

# ======== Objects for bastion subnet (public subnet)

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway tf-demo21-public-ig {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo21-public-ig"
  vcn_id         = oci_core_vcn.tf-demo21-vcn.id
}

# ------ Create a new Route Table
resource oci_core_route_table tf-demo21-public-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo21-vcn.id
  display_name   = "tf-demo21-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.tf-demo21-public-ig.id
  }
}

# ------ Create a new security list to be used in the new subnet
resource oci_core_security_list tf-demo21-bastion-subnet-sl {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo21-bastion-subnet-seclist"
  vcn_id         = oci_core_vcn.tf-demo21-vcn.id

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

# ------ Create a public regional subnet in the new VCN
resource oci_core_subnet tf-demo21-bastion-subnet {
  cidr_block          = var.cidr_subnet_public
  display_name        = "tf-demo21-bastion-subnet"
  dns_label           = "bastion"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf-demo21-vcn.id
  route_table_id      = oci_core_route_table.tf-demo21-public-rt.id
  security_list_ids   = [oci_core_security_list.tf-demo21-bastion-subnet-sl.id]
  dhcp_options_id     = oci_core_vcn.tf-demo21-vcn.default_dhcp_options_id
}

# ======== Objects for private subnet

# ------ Create a new Services Gategay
data oci_core_services services {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource oci_core_service_gateway tf-demo21-private-sgw {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo21-vcn.id
  services {
    service_id = lookup(data.oci_core_services.services.services[0], "id")
  }
  display_name   = "tf-demo21-private-sgw"
}

# ------ Create a NAT gateway
resource oci_core_nat_gateway tf-demo21-private-natgw {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo21-vcn.id
  display_name   = "tf-demo21-private-natgw"
}

# ------ Create a new Route Table
resource oci_core_route_table tf-demo21-private-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo21-vcn.id
  display_name   = "tf-demo21-private-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.tf-demo21-private-natgw.id
  }

  route_rules {
    destination       = lookup(data.oci_core_services.services.services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.tf-demo21-private-sgw.id
  }
}

# ------ Create a new security list to be used in the new subnet
resource oci_core_security_list tf-demo21-private-subnet-sl {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo21-private-subnet-seclist"
  vcn_id         = oci_core_vcn.tf-demo21-vcn.id

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
resource oci_core_subnet tf-demo21-private-subnet {
  cidr_block          = var.cidr_subnet_private
  display_name        = "tf-demo21-private-subnet"
  dns_label           = "private"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf-demo21-vcn.id
  route_table_id      = oci_core_route_table.tf-demo21-private-rt.id
  security_list_ids   = [oci_core_security_list.tf-demo21-private-subnet-sl.id]
  dhcp_options_id     = oci_core_vcn.tf-demo21-vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = true
}

