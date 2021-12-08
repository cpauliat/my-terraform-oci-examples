# ------ Create a new VCN
resource oci_core_vcn demo47-vcn {
  cidr_blocks    = [ var.vcn_cidr ]
  compartment_id = var.compartment_ocid
  display_name   = "demo47-vcn"
  dns_label      = var.vcn_dnslabel
}

# ========== Objects for public bastion subnet 

# ------ Create a new Internet Gategay for public subnet
resource oci_core_internet_gateway demo47-ig {
  compartment_id = var.compartment_ocid
  display_name   = "demo47-internet-gateway"
  vcn_id         = oci_core_vcn.demo47-vcn.id
}

# ------ Create a new Route Table for public subnet
resource oci_core_route_table demo47-rt-public {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.demo47-vcn.id
  display_name   = "demo47-public-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.demo47-ig.id
    description       = "Default route to INTERNET gateway"
  }
}

# ------ Create a new security list to be used in the new subnet
resource oci_core_security_list demo47-sl-public {
  compartment_id = var.compartment_ocid
  display_name   = "demo47-public-seclist"
  vcn_id         = oci_core_vcn.demo47-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outgoing traffic"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.vcn_cidr
  }

  dynamic "ingress_security_rules" {
    for_each = var.authorized_ips
    content {
        protocol    = "6" # tcp
        source      = ingress_security_rules.value["ip"]
        description = "Allow SSH from ${ingress_security_rules.value["description"]}"
        tcp_options {
          min = 22
          max = 22
        }
    }
  }

  dynamic "ingress_security_rules" {
    for_each = var.authorized_ips
    content {
        protocol    = "1" # icmp
        source      = ingress_security_rules.value["ip"]
        icmp_options {
          type = 3
          code = 4
        }
    }
  }
}

# ------ Create a regional public subnet
resource oci_core_subnet demo47-public-subnet {
  cidr_block          = var.cidr_public_subnet
  display_name        = "bastion_public"
  dns_label           = "public"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.demo47-vcn.id
  route_table_id      = oci_core_route_table.demo47-rt-public.id
  security_list_ids   = [oci_core_security_list.demo47-sl-public.id]
  dhcp_options_id     = oci_core_vcn.demo47-vcn.default_dhcp_options_id
}

# ========== Objects for private subnets

# ------ Create a NAT gateway
resource oci_core_nat_gateway demo47-natgw {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.demo47-vcn.id
  display_name   = "demo47-nat-gateway"
}

# ------ Create a Dynamic Routing Gateway (DRG) in the new VCN and attach it to the VCN (needed for FastConnect)
#        FastConnect link to be created manually in OCI console and attached to this DRG
resource oci_core_drg demo47-drg {
  compartment_id      = var.compartment_ocid
  display_name        = "DRG_for_FastConnect"
}

resource oci_core_drg_attachment demo47-drg {
  drg_id   = oci_core_drg.demo47-drg.id
  vcn_id   = oci_core_vcn.demo47-vcn.id
}

# ------ Create a new Services Gategay to access Oracle services from private subnet
data oci_core_services services {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource oci_core_service_gateway demo47-sgw {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.demo47-vcn.id
  services {
    service_id = lookup(data.oci_core_services.services.services[0], "id")
  }
  display_name   = "demo47-svc-gateway"
}

# ------ Create a new Route Table to be used in the new private subnet
resource oci_core_route_table demo47-rt-private {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.demo47-vcn.id
  display_name   = "demo47-rt-private"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.demo47-natgw.id
    description       = "Default route to NAT gateway"
  }

  route_rules {
    destination       = var.cidr_onprem
    network_entity_id = oci_core_drg.demo47-drg.id
    description       = "Route to ON-PREMISES network thru FastConnect"
  }

  route_rules {
    destination       = lookup(data.oci_core_services.services.services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.demo47-sgw.id
    description       = "Route to some Oracle cloud Services from private subnet"
  }
}

# ------ Create 1 security list for each private subnet
resource oci_core_security_list demo47-sl-privates {
  count          = length(var.private_subnets)
  compartment_id = var.compartment_ocid
  display_name   = "${lookup(var.private_subnets[count.index], "name")}-sl"
  vcn_id         = oci_core_vcn.demo47-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outgoing traffic"
  }

  # TCP ingress rules
  dynamic ingress_security_rules {
    for_each = lookup(var.private_subnets[count.index], "ingress_rules_tcp")
    content {
      protocol    = "6" # tcp
      source      = lookup(ingress_security_rules.value, "source")
      description = "tcp rule"
      tcp_options {
        min = lookup(ingress_security_rules.value, "port_min")
        max = lookup(ingress_security_rules.value, "port_max")
      }
    }
  }

  # UDP egress rules
  dynamic ingress_security_rules {
    for_each = lookup(var.private_subnets[count.index], "ingress_rules_udp")
    content {
      protocol    = "17" # udp
      source      = lookup(ingress_security_rules.value, "source")
      description = "udp rule"
      udp_options {
        min = lookup(ingress_security_rules.value, "port_min")
        max = lookup(ingress_security_rules.value, "port_max")
      }
    }
  }

  # ICMP egress rules
  dynamic ingress_security_rules {
    for_each = lookup(var.private_subnets[count.index], "ingress_rules_icmp")
    content {
      protocol    = "1" # icmp
      source      = lookup(ingress_security_rules.value, "source")
      description = "icmp rule"
    }
  }

}

# ------ Create several regional private subnets
resource oci_core_subnet demo47-private-subnet {
  count               = length(var.private_subnets)
  cidr_block          = lookup(var.private_subnets[count.index], "cidr")
  display_name        = lookup(var.private_subnets[count.index], "name")
  dns_label           = lookup(var.private_subnets[count.index], "dnslabel")
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.demo47-vcn.id
  route_table_id      = oci_core_route_table.demo47-rt-private.id
  security_list_ids   = [ oci_core_security_list.demo47-sl-privates[count.index].id ]
  dhcp_options_id     = oci_core_vcn.demo47-vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = true
}
