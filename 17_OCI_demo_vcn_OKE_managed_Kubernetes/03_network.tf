# ------ Create a new VCN
resource oci_core_vcn demo17-vcn {
  cidr_blocks    = [ var.cidr_vcn ]
  compartment_id = var.compartment_ocid
  display_name   = "demo17-oke-vcn"
  dns_label      = "demo17"
}

# ========== Common resources in the VCN

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway demo17-ig {
  compartment_id = var.compartment_ocid
  display_name   = "demo17-internet-gateway"
  vcn_id         = oci_core_vcn.demo17-vcn.id
}

# ------ Create a NAT gateway
resource oci_core_nat_gateway demo17-natgw {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.demo17-vcn.id
  display_name   = "demo17-nat-gateway"
}

# ------ Create a new Services gategay
data oci_core_services services {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource oci_core_service_gateway demo17-sgw {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.demo17-vcn.id
  services {
    service_id = lookup(data.oci_core_services.services.services[0], "id")
  }
  display_name   = "demo17-svc-gateway"
}

# ------ Create a new Route Table for public subnets
resource oci_core_route_table demo17-rt-public {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.demo17-vcn.id
  display_name   = "demo17-route-table-public"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.demo17-ig.id
  }
}

# ============ WORKER NODES private subnet and related resources

resource oci_core_route_table demo17-rt-workers {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.demo17-vcn.id
  display_name   = "demo17-rt-workers"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.demo17-natgw.id
    description       = "Default route to NAT gateway"
  }

  route_rules {
    destination       = lookup(data.oci_core_services.services.services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.demo17-sgw.id
    description       = "Route to some Oracle cloud Services from private subnet"
  }
}

# ------ Create a new security list for workers subnets
resource oci_core_security_list demo17-sl-workers {
  compartment_id = var.compartment_ocid
  display_name   = "demo17-sl-workers"
  vcn_id         = oci_core_vcn.demo17-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outgoing traffic"
  }

  ingress_security_rules {
    protocol    = "all"
    source      = var.cidr_vcn
    description = "Allow all traffic from VCN"
  }
}

# ------ Create a private public subnet for worker nodes
resource oci_core_subnet demo17-workers {
  cidr_block          = var.cidr_workers
  display_name        = "demo17-workers"
  dns_label           = "workers"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.demo17-vcn.id
  route_table_id      = oci_core_route_table.demo17-rt-workers.id
  security_list_ids   = [ oci_core_security_list.demo17-sl-workers.id ]
  dhcp_options_id     = oci_core_vcn.demo17-vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = true
}

# ============ PUBLIC ENDPOINT public subnet related resources

# ------ Create a new security list
resource oci_core_security_list demo17-sl-api-endpoint {
  compartment_id = var.compartment_ocid
  display_name   = "demo17-sl-api-endpoint"
  vcn_id         = oci_core_vcn.demo17-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"   
    description = "Allow all outgoing traffic"
  }

  ingress_security_rules {
    protocol    = "all"
    source      = var.cidr_vcn
    description = "Allow all traffic from VCN"
  }

  ingress_security_rules {
    protocol = "1"   # icmp
    source   = var.authorized_ips
    description = "Path discovery"
    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    protocol    = "6"   # tcp
    source      = "0.0.0.0/0" # var.authorized_ips
    description = "Allow access to Kubernetes API Public Endpoint (for kubectl) from authorised IP address range"
    tcp_options {
      min = 6443
      max = 6443
    }
  }
}

# ------ Create a regional public subnet for API endpoint
resource oci_core_subnet demo17-api-endpoint {
  cidr_block          = var.cidr_api_endpoint
  display_name        = "demo17-api-endpoint"
  dns_label           = "api"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.demo17-vcn.id
  route_table_id      = oci_core_route_table.demo17-rt-public.id
  security_list_ids   = [ oci_core_security_list.demo17-sl-api-endpoint.id ]
  dhcp_options_id     = oci_core_vcn.demo17-vcn.default_dhcp_options_id
}

# ============ LOAD BALANCERS public subnet and related resources

# ------ Create a new security list
resource oci_core_security_list demo17-sl-lbs {
  compartment_id = var.compartment_ocid
  display_name   = "demo17-sl-lbs"
  vcn_id         = oci_core_vcn.demo17-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"   
    description = "Allow all outgoing traffic"
  }

  ingress_security_rules {
    protocol    = "all"
    source      = var.cidr_vcn
    description = "Allow all traffic from VCN"
  }

  ingress_security_rules {
    protocol = "6"   # tcp
    source   = var.authorized_ips
    description = "Allow HTTPS access to future OCI load balancers from authorized ip"
    tcp_options {
      min = 443
      max = 443
    }
  }

  ingress_security_rules {
    protocol = "6"   # tcp
    source   = var.authorized_ips
    description = "Allow HTTP access to future OCI load balancers from authorized ip"
    tcp_options {
      min = 80
      max = 80
    }
  }
}

# ------ Create a regional public subnet
resource oci_core_subnet demo17-lbs {
  cidr_block          = var.cidr_lbs
  display_name        = "demo17-lb"
  dns_label           = "lbs"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.demo17-vcn.id
  route_table_id      = oci_core_route_table.demo17-rt-public.id
  security_list_ids   = [ oci_core_security_list.demo17-sl-lbs.id ]
  dhcp_options_id     = oci_core_vcn.demo17-vcn.default_dhcp_options_id
}

# ============ BASTION public subnet and related resources

# ------ Create a new security list
resource oci_core_security_list demo17-sl-bastion {
  compartment_id = var.compartment_ocid
  display_name   = "demo17-sl-bastion"
  vcn_id         = oci_core_vcn.demo17-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"   
    description = "Allow all outgoing traffic"
  }

  ingress_security_rules {
    protocol    = "all"
    source      = var.cidr_vcn
    description = "Allow all traffic from VCN"
  }

  ingress_security_rules {
    protocol = "1"   # icmp
    source   = var.authorized_ips
    description = "Path discovery"
    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    protocol    = "6"   # tcp
    source      = var.authorized_ips
    description = "Allow SSH access to Bastion from authorised IP address range"
    tcp_options {
      min = 22
      max = 22
    }
  }
}

# ------ Create a regional public subnet for BASTION
resource oci_core_subnet demo17-bastion {
  cidr_block          = var.cidr_bastion
  display_name        = "demo17-bastion"
  dns_label           = "bastion"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.demo17-vcn.id
  route_table_id      = oci_core_route_table.demo17-rt-public.id
  security_list_ids   = [ oci_core_security_list.demo17-sl-bastion.id ]
  dhcp_options_id     = oci_core_vcn.demo17-vcn.default_dhcp_options_id
}