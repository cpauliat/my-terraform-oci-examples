# -------- get the list of available ADs
data oci_identity_availability_domains r2ADs {
  provider       = oci.r2
  compartment_id = var.tenancy_ocid
}

# ------ Create a new VCN in region 2
resource oci_core_vcn r2-vcn {
  provider       = oci.r2
  cidr_blocks    = [ var.r2_cidr_vcn ]
  compartment_id = var.r2_compartment_ocid
  display_name   = "demo13_r2_vcn"
  dns_label      = var.dns_label_vcn2
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway r2-ig {
  provider       = oci.r2
  compartment_id = var.r2_compartment_ocid
  display_name   = "rdemo13_r2_igw"
  vcn_id         = oci_core_vcn.r2-vcn.id
}

# ------ Create a new Route Table for the public subnet
resource oci_core_route_table r2-pubnet-rt {
  provider       = oci.r2
  compartment_id = var.r2_compartment_ocid
  vcn_id         = oci_core_vcn.r2-vcn.id
  display_name   = "demo13_r2_pubnet_rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.r2-ig.id
  }

  route_rules {
    destination       = var.r1_cidr_vcn
    network_entity_id = oci_core_drg.r2_drg.id
  }
}

# ------ Create a new Route Table for the private subnet
resource oci_core_route_table r2-privnet-rt {
  provider       = oci.r2
  compartment_id = var.r2_compartment_ocid
  vcn_id         = oci_core_vcn.r2-vcn.id
  display_name   = "demo13_r2_privnet_rt"

  route_rules {
    destination       = var.r1_cidr_vcn
    network_entity_id = oci_core_drg.r2_drg.id
  }
}

# ------ Create a new security list to be used in the new public subnet
resource oci_core_security_list r2-pubnet-sl {
  provider       = oci.r2
  compartment_id = var.r2_compartment_ocid
  display_name   = "demo13_r2_pubnet_sl"
  vcn_id         = oci_core_vcn.r2-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.r2_cidr_vcn
  }
  ingress_security_rules {
    protocol = "all"
    source   = var.r1_cidr_vcn
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
resource oci_core_security_list r2-privnet-sl {
  provider       = oci.r2
  compartment_id = var.r2_compartment_ocid
  display_name   = "demo13_r2_privnet_sl"
  vcn_id         = oci_core_vcn.r2-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.r2_cidr_privnet
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
resource oci_core_subnet r2-pubnet {
  provider            = oci.r2
  cidr_block          = var.r2_cidr_pubnet
  display_name        = "demo13_r2_pubnet"
  dns_label           = var.dns_label_public2
  compartment_id      = var.r2_compartment_ocid
  vcn_id              = oci_core_vcn.r2-vcn.id
  route_table_id      = oci_core_route_table.r2-pubnet-rt.id
  security_list_ids   = [oci_core_security_list.r2-pubnet-sl.id]
  dhcp_options_id     = oci_core_vcn.r2-vcn.default_dhcp_options_id
}

# ------ Create a private subnet in the new VCN
resource oci_core_subnet r2-privnet {
  provider            = oci.r2
  cidr_block          = var.r2_cidr_privnet
  display_name        = "demo13_r2_privnet"
  dns_label           = var.dns_label_private2
  compartment_id      = var.r2_compartment_ocid
  vcn_id              = oci_core_vcn.r2-vcn.id
  route_table_id      = oci_core_route_table.r2-privnet-rt.id
  security_list_ids   = [oci_core_security_list.r2-privnet-sl.id]
  dhcp_options_id     = oci_core_vcn.r2-vcn.default_dhcp_options_id
}

# ------ Create a Dynamic Routing Gateway (DRG) in the new VCN and attach it to the VCN
resource oci_core_drg r2_drg {
  provider       = oci.r2
  compartment_id = var.r2_compartment_ocid
}

resource oci_core_drg_attachment r2_drg_attachment {
  provider = oci.r2
  drg_id   = oci_core_drg.r2_drg.id
  vcn_id   = oci_core_vcn.r2-vcn.id
}

# ------ Enable the remote VCN peering (region2 = requestor)
resource oci_core_remote_peering_connection r2-requestor {
  provider         = oci.r2
  compartment_id   = var.r2_compartment_ocid
  drg_id           = oci_core_drg.r2_drg.id
  display_name     = "remotePeeringConnectionR2"
  peer_id          = oci_core_remote_peering_connection.r1-acceptor.id
  peer_region_name = var.region1
}

