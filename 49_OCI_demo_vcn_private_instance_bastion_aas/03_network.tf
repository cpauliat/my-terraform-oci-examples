# ------ Create a new VCN with a single subnet (private)
resource oci_core_vcn demo49-vcn {
  cidr_blocks    = [ var.cidr_vcn ]
  compartment_id = var.compartment_ocid
  display_name   = "demo49-vcn"
  dns_label      = "demo49"
}

# ========== Objects for private subnet

# ------ Create a NAT gateway
resource oci_core_nat_gateway demo49-natgw {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.demo49-vcn.id
  display_name   = "demo49-nat-gateway"
}

# ------ Create a new Services Gategay to access Oracle services from private subnet
data oci_core_services services {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource oci_core_service_gateway demo49-sgw {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.demo49-vcn.id
  services {
    service_id = lookup(data.oci_core_services.services.services[0], "id")
  }
  display_name   = "demo49-svc-gateway"
}

# ------ Create a new Route Table to be used in the new private subnet
resource oci_core_route_table demo49-rt-private {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.demo49-vcn.id
  display_name   = "demo49-rt-private"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.demo49-natgw.id
    description       = "Default route to NAT Gateway"
  }

  route_rules {
    destination       = lookup(data.oci_core_services.services.services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.demo49-sgw.id
    description       = "Route to some Oracle cloud Services from private subnet"
  }
}

# ------ Create a new security list to be used in the new private subnet
resource oci_core_security_list demo49-subnet-sl-private {
  compartment_id = var.compartment_ocid
  display_name   = "demo49-sl-private"
  vcn_id         = oci_core_vcn.demo49-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outgoing traffic"
  }

  ingress_security_rules {
    protocol    = "6" # tcp
    source      = var.cidr_private_subnet
    description = "Allow SSH access to Linux private instance from Bastion as a Service private endpoint"
    tcp_options {
      min = 22
      max = 22
    }
  }
}

# ------ Create a regional private subnet (for the web servers)
resource oci_core_subnet demo49-private-subnet {
  cidr_block                 = var.cidr_private_subnet
  display_name               = "demo49-private-subnet"
  dns_label                  = "private"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.demo49-vcn.id
  route_table_id             = oci_core_route_table.demo49-rt-private.id
  security_list_ids          = [ oci_core_security_list.demo49-subnet-sl-private.id ]
  dhcp_options_id            = oci_core_vcn.demo49-vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = true
}
