# ------ Create a new VCN
resource oci_core_vcn vcn1-vcn {
  cidr_blocks    = [ var.vcn1_cidr_vcn ]
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo12-vcn1"
  dns_label      = var.dns_label_vcn1
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway vcn1-ig {
  compartment_id = var.compartment_ocid
  display_name   = "demo12_vcn1_igw"
  vcn_id         = oci_core_vcn.vcn1-vcn.id
}

# ------ Create a new Route Table for the public subnet
resource oci_core_route_table vcn1-pubnet-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn1-vcn.id
  display_name   = "demo12_vcn1_pubnet_rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.vcn1-ig.id
  }

  route_rules {
    destination       = var.vcn2_cidr_vcn
    network_entity_id = oci_core_local_peering_gateway.vcn1-lpg.id
  }
}

# ------ Create a new Route Table for the private subnet
resource oci_core_route_table vcn1-privnet-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn1-vcn.id
  display_name   = "demo12_vcn1_privnet_rt"

  route_rules {
    destination       = var.vcn2_cidr_vcn
    network_entity_id = oci_core_local_peering_gateway.vcn1-lpg.id
  }
}

# ------ Create a new security list to be used in the new public subnet
resource oci_core_security_list vcn1-pubnet-sl {
  compartment_id = var.compartment_ocid
  display_name   = "demo12_vcn1_pubnet_sl"
  vcn_id         = oci_core_vcn.vcn1-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.vcn1_cidr_vcn
  }
  ingress_security_rules {
    protocol = "all"
    source   = var.vcn2_cidr_vcn
  }
  ingress_security_rules {
    protocol = "6" # tcp
    source   = var.authorized_ips

    tcp_options {
      min = 22
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

# ------ Create a new security list to be used in the new private subnet
resource oci_core_security_list vcn1-privnet-sl {
  compartment_id = var.compartment_ocid
  display_name   = "demo12_vcn1_privnet_sl"
  vcn_id         = oci_core_vcn.vcn1-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.vcn1_cidr_privnet
  }
  ingress_security_rules {
    protocol = "6" # tcp
    source   = var.authorized_ips

    tcp_options {
      min = 22
      max = 22
    }
  }
}

# ------ Create a public subnet in the new VCN
resource oci_core_subnet vcn1-pubnet {
  cidr_block          = var.vcn1_cidr_pubnet
  display_name        = "demo12_vcn1_pubnet"
  dns_label           = var.dns_label_public1
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.vcn1-vcn.id
  route_table_id      = oci_core_route_table.vcn1-pubnet-rt.id
  security_list_ids   = [oci_core_security_list.vcn1-pubnet-sl.id]
  dhcp_options_id     = oci_core_vcn.vcn1-vcn.default_dhcp_options_id
}

# ------ Create a private subnet in the new VCN
resource oci_core_subnet vcn1-privnet {
  cidr_block          = var.vcn1_cidr_privnet
  display_name        = "demo12_vcn1_privnet"
  dns_label           = var.dns_label_private1
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.vcn1-vcn.id
  route_table_id      = oci_core_route_table.vcn1-privnet-rt.id
  security_list_ids   = [oci_core_security_list.vcn1-privnet-sl.id]
  dhcp_options_id     = oci_core_vcn.vcn1-vcn.default_dhcp_options_id
}

# ------ Create a Local Peering Gateway (LPG) in the new VCN
resource oci_core_local_peering_gateway vcn1-lpg {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn1-vcn.id
  display_name   = "lpg1"
  peer_id        = oci_core_local_peering_gateway.vcn2-lpg.id
}
