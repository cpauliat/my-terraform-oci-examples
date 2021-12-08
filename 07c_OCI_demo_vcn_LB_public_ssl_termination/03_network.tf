# ------ Create a new VCN
resource oci_core_vcn tf-demo07c-vcn {
  cidr_blocks    = [ var.cidr_vcn ]
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo07c-vcn"
  dns_label      = "demo07c"
}

# ========== Objects for public subnet

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway tf-demo07c-ig {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo07c-internet-gateway"
  vcn_id         = oci_core_vcn.tf-demo07c-vcn.id
}

# ------ Create a new Route Table to be used in the new public subnet
resource oci_core_route_table tf-demo07c-rt-public {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo07c-vcn.id
  display_name   = "tf-demo07c-rt-public"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.tf-demo07c-ig.id
    description       = "Default route to Internet Gateway"
  }
}

# ------ Create a new security list to be used in the new public subnet
resource oci_core_security_list tf-demo07c-subnet-sl-public {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo07c-sl-public"
  vcn_id         = oci_core_vcn.tf-demo07c-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outgoing traffic"
  }

  # see https://www.terraform.io/docs/language/expressions/dynamic-blocks.html
  dynamic "ingress_security_rules" {
    for_each = var.authorized_ips_list
    content {
        protocol    = "6" # tcp
        source      = ingress_security_rules.value["cidr"]
        description = "Allow SSH from ${ingress_security_rules.value["desc"]}"
        tcp_options {
          min = 22
          max = 22
        }
    }
  }

  # ingress_security_rules {
  #   protocol    = "6" # tcp
  #   source      = "0.0.0.0/0"
  #   description = "Allow HTTP access from all Internet"
  #   tcp_options {
  #     min = 80
  #     max = 80
  #   }
  # }

  ingress_security_rules {
    protocol    = "6" # tcp
    source      = "0.0.0.0/0"
    description = "Allow HTTPS access from all Internet"
    tcp_options {
      min = 443
      max = 443
    }
  }
}

# ------ Create a region public subnet (for bastion host and public load balancer)
resource oci_core_subnet tf-demo07c-public-subnet {
  cidr_block          = var.cidr_public_subnet
  display_name        = "tf-demo07c-public-subnet"
  dns_label           = "public"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf-demo07c-vcn.id
  route_table_id      = oci_core_route_table.tf-demo07c-rt-public.id
  security_list_ids   = [oci_core_security_list.tf-demo07c-subnet-sl-public.id]
  dhcp_options_id     = oci_core_vcn.tf-demo07c-vcn.default_dhcp_options_id
}

# ========== Objects for private subnet

# ------ Create a NAT gateway
resource oci_core_nat_gateway tf-demo07c-natgw {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo07c-vcn.id
  display_name   = "tf-demo07c-nat-gateway"
}

# ------ Create a new Route Table to be used in the new private subnet
resource oci_core_route_table tf-demo07c-rt-private {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo07c-vcn.id
  display_name   = "tf-demo07c-rt-private"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.tf-demo07c-natgw.id
    description       = "Default route to NAT Gateway"
  }
}

# ------ Create a new security list to be used in the new private subnet
resource oci_core_security_list tf-demo07c-subnet-sl-private {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo07c-sl-private"
  vcn_id         = oci_core_vcn.tf-demo07c-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outgoing traffic"
  }

  ingress_security_rules {
    protocol = "all" 
    source   = "0.0.0.0/0"
    description = "Allow all traffic within VCN"
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
resource oci_core_subnet tf-demo07c-private-subnet {
  cidr_block                 = var.cidr_private_subnet
  display_name               = "tf-demo07c-private-subnet"
  dns_label                  = "private"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.tf-demo07c-vcn.id
  route_table_id             = oci_core_route_table.tf-demo07c-rt-private.id
  security_list_ids          = [oci_core_security_list.tf-demo07c-subnet-sl-private.id]
  dhcp_options_id            = oci_core_vcn.tf-demo07c-vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = true
}
