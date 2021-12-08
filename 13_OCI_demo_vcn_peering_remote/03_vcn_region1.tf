# -------- get the list of available ADs
data oci_identity_availability_domains r1ADs {
  provider       = oci.r1
  compartment_id = var.tenancy_ocid
}

# ------ Create a new VCN in region 1
resource oci_core_vcn r1-vcn {
  provider       = oci.r1
  cidr_blocks    = [ var.r1_cidr_vcn ]
  compartment_id = var.r1_compartment_ocid
  display_name   = "demo13_r1_vcn"
  dns_label      = var.dns_label_vcn1
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway r1-ig {
  provider       = oci.r1
  compartment_id = var.r1_compartment_ocid
  display_name   = "demo13_r1_igw"
  vcn_id         = oci_core_vcn.r1-vcn.id
}

# ------ Create a new Route Table for the public subnet
resource oci_core_route_table r1-pubnet-rt {
  provider       = oci.r1
  compartment_id = var.r1_compartment_ocid
  vcn_id         = oci_core_vcn.r1-vcn.id
  display_name   = "demo13_r1_pubnet_rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.r1-ig.id
  }

  route_rules {
    destination       = var.r2_cidr_vcn
    network_entity_id = oci_core_drg.r1_drg.id
  }
}

# ------ Create a new Route Table for the private subnet
resource oci_core_route_table r1-privnet-rt {
  provider       = oci.r1
  compartment_id = var.r1_compartment_ocid
  vcn_id         = oci_core_vcn.r1-vcn.id
  display_name   = "demo13_r1_privnet_rt"

  route_rules {
    destination       = var.r2_cidr_vcn
    network_entity_id = oci_core_drg.r1_drg.id
  }
}

# ------ Create a new security list to be used in the new public subnet
resource oci_core_security_list r1-pubnet-sl {
  provider       = oci.r1
  compartment_id = var.r1_compartment_ocid
  display_name   = "demo13_r1_pubnet_sl"
  vcn_id         = oci_core_vcn.r1-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.r1_cidr_vcn
  }
  ingress_security_rules {
    protocol = "all"
    source   = var.r2_cidr_vcn
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
resource oci_core_security_list r1-privnet-sl {
  provider       = oci.r1
  compartment_id = var.r1_compartment_ocid
  display_name   = "demo13_r1_privnet_sl"
  vcn_id         = oci_core_vcn.r1-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.r1_cidr_privnet
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
resource oci_core_subnet r1-pubnet {
  provider            = oci.r1
  cidr_block          = var.r1_cidr_pubnet
  display_name        = "demo13_r1_pubnet"
  dns_label           = var.dns_label_public1
  compartment_id      = var.r1_compartment_ocid
  vcn_id              = oci_core_vcn.r1-vcn.id
  route_table_id      = oci_core_route_table.r1-pubnet-rt.id
  security_list_ids   = [oci_core_security_list.r1-pubnet-sl.id]
  dhcp_options_id     = oci_core_vcn.r1-vcn.default_dhcp_options_id
}

# ------ Create a private subnet in the new VCN
resource oci_core_subnet r1-privnet {
  provider            = oci.r1
  cidr_block          = var.r1_cidr_privnet
  display_name        = "demo13_r1_privnet"
  dns_label           = var.dns_label_private1
  compartment_id      = var.r1_compartment_ocid
  vcn_id              = oci_core_vcn.r1-vcn.id
  route_table_id      = oci_core_route_table.r1-privnet-rt.id
  security_list_ids   = [oci_core_security_list.r1-privnet-sl.id]
  dhcp_options_id     = oci_core_vcn.r1-vcn.default_dhcp_options_id
}

# ------ Create a Dynamic Routing Gateway (DRG) in the new VCN and attach it to the VCN
resource oci_core_drg r1_drg {
  provider       = oci.r1
  compartment_id = var.r1_compartment_ocid
}

resource oci_core_drg_attachment r1_drg_attachment {
  provider = oci.r1
  drg_id   = oci_core_drg.r1_drg.id
  vcn_id   = oci_core_vcn.r1-vcn.id
}

# ------ Enable the remote VCN peering (region1 = acceptor)
resource oci_core_remote_peering_connection r1-acceptor {
  provider       = oci.r1
  compartment_id = var.r1_compartment_ocid
  drg_id         = oci_core_drg.r1_drg.id
  display_name   = "remotePeeringConnectionR1"
}

