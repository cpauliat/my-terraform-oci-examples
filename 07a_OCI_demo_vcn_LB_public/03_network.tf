# ------ Create a new VCN
resource oci_core_vcn tf-demo07a-vcn {
  cidr_blocks    = [ var.cidr_vcn ]
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo07a-vcn"
  dns_label      = "demo07a"
}

# ========== Objects for public subnet

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway tf-demo07a-ig {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo07a-internet-gateway"
  vcn_id         = oci_core_vcn.tf-demo07a-vcn.id
}

# ------ Create a new Route Table to be used in the new public subnet
resource oci_core_route_table tf-demo07a-rt-public {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo07a-vcn.id
  display_name   = "tf-demo07a-rt-public"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.tf-demo07a-ig.id
    description       = "Default route to Internet Gateway"
  }
}

# ------ Create a new security list to be used in the new public subnet
resource oci_core_security_list tf-demo07a-subnet-sl-public {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo07a-sl-public"
  vcn_id         = oci_core_vcn.tf-demo07a-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outgoing traffic"
  }

  ingress_security_rules {
    protocol    = "6" # tcp
    source      = var.authorized_ips
    description = "Allow SSH from authorized public IP address"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol    = "6" # tcp
    source      = "0.0.0.0/0"
    description = "Allow HTTP from authorized public IP address"
    tcp_options {
      min = 80
      max = 80
    }
  }
}

# ------ Create a region public subnet (for bastion host and public load balancer)
resource oci_core_subnet tf-demo07a-public-subnet {
  cidr_block          = var.cidr_public_subnet
  display_name        = "tf-demo07a-public-subnet"
  dns_label           = "public"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf-demo07a-vcn.id
  route_table_id      = oci_core_route_table.tf-demo07a-rt-public.id
  security_list_ids   = [oci_core_security_list.tf-demo07a-subnet-sl-public.id]
  dhcp_options_id     = oci_core_vcn.tf-demo07a-vcn.default_dhcp_options_id
}

# ========== Objects for private subnet

# ------ Create a NAT gateway
resource oci_core_nat_gateway tf-demo07a-natgw {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo07a-vcn.id
  display_name   = "tf-demo07a-nat-gateway"
}

# ------ Create a new Route Table to be used in the new private subnet
resource oci_core_route_table tf-demo07a-rt-private {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo07a-vcn.id
  display_name   = "tf-demo07a-rt-private"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.tf-demo07a-natgw.id
    description       = "Default route to NAT Gateway"
  }
}

# ------ Create a new security list to be used in the new private subnet
resource oci_core_security_list tf-demo07a-subnet-sl-private {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo07a-sl-private"
  vcn_id         = oci_core_vcn.tf-demo07a-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outgoing traffic"
  }

  ingress_security_rules {
    protocol = "6" # tcp
    source   = var.cidr_public_subnet
    description = "Allow HTTP access from public load balancer"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol    = "6" # tcp
    source      = var.cidr_public_subnet
    description = "Allow SSH access from bastion host"
    tcp_options {
      min = 22
      max = 22
    }
  }
}

# ------ Create a regional private subnet (for the web servers)
resource oci_core_subnet tf-demo07a-private-subnet {
  cidr_block                 = var.cidr_private_subnet
  display_name               = "tf-demo07a-private-subnet"
  dns_label                  = "private"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.tf-demo07a-vcn.id
  route_table_id             = oci_core_route_table.tf-demo07a-rt-private.id
  security_list_ids          = [oci_core_security_list.tf-demo07a-subnet-sl-private.id]
  dhcp_options_id            = oci_core_vcn.tf-demo07a-vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = true
}
