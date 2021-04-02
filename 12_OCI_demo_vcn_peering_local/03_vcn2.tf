# -------- get the list of available ADs
data oci_identity_availability_domains vcn2ADs {
  compartment_id = var.tenancy_ocid
}

# ------ Create a new VCN
resource oci_core_virtual_network vcn2-vcn {
  cidr_block     = var.vcn2_cidr_vcn
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo12-vcn2"
  dns_label      = "vcn2"
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway vcn2-ig {
  compartment_id = var.compartment_ocid
  display_name   = "demo12_vcn2_igw"
  vcn_id         = oci_core_virtual_network.vcn2-vcn.id
}

# ------ Create a new Route Table for the public subnet
resource oci_core_route_table vcn2-pubnet-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn2-vcn.id
  display_name   = "demo12_vcn2_pubnet_rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.vcn2-ig.id
  }

  route_rules {
    destination       = var.vcn1_cidr_vcn
    network_entity_id = oci_core_local_peering_gateway.vcn2-lpg.id
  }
}

# ------ Create a new Route Table for the private subnet
resource oci_core_route_table vcn2-privnet-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn2-vcn.id
  display_name   = "demo12_vcn2_privnet_rt"

  route_rules {
    destination       = var.vcn1_cidr_vcn
    network_entity_id = oci_core_local_peering_gateway.vcn2-lpg.id
  }
}

# ------ Create a new security list to be used in the new public subnet
resource oci_core_security_list vcn2-pubnet-sl {
  compartment_id = var.compartment_ocid
  display_name   = "demo12_vcn2_pubnet_sl"
  vcn_id         = oci_core_virtual_network.vcn2-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.vcn2_cidr_vcn
  }
  ingress_security_rules {
    protocol = "all"
    source   = var.vcn1_cidr_vcn
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
resource oci_core_security_list vcn2-privnet-sl {
  compartment_id = var.compartment_ocid
  display_name   = "demo12_vcn2_privnet_sl"
  vcn_id         = oci_core_virtual_network.vcn2-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.vcn2_cidr_vcn
  }
  ingress_security_rules {
    protocol = "all"
    source   = var.vcn1_cidr_vcn
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
resource oci_core_subnet vcn2-pubnet {
  cidr_block          = var.vcn2_cidr_pubnet
  display_name        = "demo12_vcn2_pubnet"
  dns_label           = "pub"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_virtual_network.vcn2-vcn.id
  route_table_id      = oci_core_route_table.vcn2-pubnet-rt.id
  security_list_ids   = [oci_core_security_list.vcn2-pubnet-sl.id]
  dhcp_options_id     = oci_core_virtual_network.vcn2-vcn.default_dhcp_options_id
}

# ------ Create a private subnet in the new VCN
resource oci_core_subnet vcn2-privnet {
  cidr_block          = var.vcn2_cidr_privnet
  display_name        = "demo12_vcn2_privnet"
  dns_label           = "priv"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_virtual_network.vcn2-vcn.id
  route_table_id      = oci_core_route_table.vcn2-privnet-rt.id
  security_list_ids   = [oci_core_security_list.vcn2-privnet-sl.id]
  dhcp_options_id     = oci_core_virtual_network.vcn2-vcn.default_dhcp_options_id
}

# ------ Create a Local Peering Gateway (LPG) in the new VCN
resource oci_core_local_peering_gateway vcn2-lpg {
  #Required
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn2-vcn.id

  #Optional
  display_name = "lpg2"
  #peer_id = "${oci_core_local_peering_gateway.test_local_peering_gateway_3_A.id}"
}
