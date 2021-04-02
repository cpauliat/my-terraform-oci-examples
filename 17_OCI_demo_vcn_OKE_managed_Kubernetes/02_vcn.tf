# ------ Create a new VCN
resource oci_core_virtual_network tf-demo17-vcn {
  cidr_block     = var.cidr_vcn
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo17-oke-vcn"
  dns_label      = "demo17"
}

# ========== Common resources in the VCN

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway tf-demo17-ig {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo17-internet-gateway"
  vcn_id         = oci_core_virtual_network.tf-demo17-vcn.id
}

# ------ Create a new Route Table
resource oci_core_route_table tf-demo17-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.tf-demo17-vcn.id
  display_name   = "tf-demo17-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.tf-demo17-ig.id
  }
}

# ============ WORKER NODES subnet and related resources

# ------ Create a new security list for worker subnets
resource oci_core_security_list tf-demo17-sl-worker {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo17-sl-worker"
  vcn_id         = oci_core_virtual_network.tf-demo17-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.cidr_worker
  }

  # -- optional: allow SSH access to worker nodes
  ingress_security_rules {
    protocol = "6"
    source   = var.authorized_ips
    tcp_options {
      min = 22
      max = 22
    }
  }
  
  ingress_security_rules {
    protocol = "1"   # icmp
    source   = var.authorized_ips
    icmp_options {
      type = 3
      code = 4
    }
  }

  # -- optional: allow inbound traffic to worker nodes
  ingress_security_rules {
    protocol = "6"  # tcp
    source   = var.authorized_ips
    tcp_options {
      min = 30000
      max = 32767
    }
  }

  # -- required: allow SSH access to worker nodes from OKE
  ingress_security_rules {
    protocol = "6" # tcp
    source   = var.cidrs_oke[0]
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol = "6" # tcp
    source   = var.cidrs_oke[1]
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol = "6" # tcp
    source   = var.cidrs_oke[2]
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol = "6" # tcp
    source   = var.cidrs_oke[3]
    tcp_options {
      min = 22
      max = 22
    }
  }  

  ingress_security_rules {
    protocol = "6" # tcp
    source   = var.cidrs_oke[4]
    tcp_options {
      min = 22
      max = 22
    }
  }  

  ingress_security_rules {
    protocol = "6" # tcp
    source   = var.cidrs_oke[5]
    tcp_options {
      min = 22
      max = 22
    }
  }  
}

# ------ Create a regional public subnet for worker nodes
# ------ (also possible to use a private network with NAT and services gateways)
resource oci_core_subnet tf-demo17-worker {
  cidr_block          = var.cidr_worker
  display_name        = "tf-demo17-worker"
  dns_label           = "worker"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_virtual_network.tf-demo17-vcn.id
  route_table_id      = oci_core_route_table.tf-demo17-rt.id
  security_list_ids   = [oci_core_security_list.tf-demo17-sl-worker.id]
  dhcp_options_id     = oci_core_virtual_network.tf-demo17-vcn.default_dhcp_options_id
}

# ============ LOAD BALANCER subnet and related resources

# ------ Create a new security list for load balancer subnet
resource oci_core_security_list tf-demo17-sl-loadbalancers {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo17-sl-loadbalancers"
  vcn_id         = oci_core_virtual_network.tf-demo17-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"   
  }
  
  ingress_security_rules {
    protocol = "all"
    source   = "0.0.0.0/0"
  }
}

# ------ Create a regional public subnet for load balancer
resource oci_core_subnet tf-demo17-lb {
  cidr_block          = var.cidr_lb
  display_name        = "tf-demo17-lb"
  dns_label           = "lb"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_virtual_network.tf-demo17-vcn.id
  route_table_id      = oci_core_route_table.tf-demo17-rt.id
  security_list_ids   = [oci_core_security_list.tf-demo17-sl-loadbalancers.id]
  dhcp_options_id     = oci_core_virtual_network.tf-demo17-vcn.default_dhcp_options_id
}
