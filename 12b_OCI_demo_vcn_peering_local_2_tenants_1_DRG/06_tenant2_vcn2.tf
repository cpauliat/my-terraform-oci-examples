# -------- get the list of available ADs
data oci_identity_availability_domains tenant2ADs {
  provider       = oci.tenant2
  compartment_id = var.tenancy_ocid2
}

# ------ Create a new VCN
resource oci_core_vcn tenant2-vcn {
  provider       = oci.tenant2
  cidr_blocks    = [ var.tenant2_cidr_vcn ]
  compartment_id = var.compartment_ocid2
  display_name   = "tf-demo12b-tenant2"
  dns_label      = var.dns_label_tenant2
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway tenant2-ig {
  provider       = oci.tenant2
  compartment_id = var.compartment_ocid2
  display_name   = "demo12b_tenant2_igw"
  vcn_id         = oci_core_vcn.tenant2-vcn.id
}

# ------ Create a new Route Table for the public subnet
resource oci_core_route_table tenant2-pubnet-rt {
  provider       = oci.tenant2
  compartment_id = var.compartment_ocid2
  vcn_id         = oci_core_vcn.tenant2-vcn.id
  display_name   = "demo12b_tenant2_pubnet_rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.tenant2-ig.id
  }

  route_rules {
    destination       = var.tenant1_cidr_vcn
    network_entity_id = oci_core_drg.tenant1-drg.id
    #OLD: using LPGs instead of DRG (soon deprecated)
    #network_entity_id = oci_core_local_peering_gateway.tenant2-lpg.id
  }
}

# ------ Create a new Route Table for the private subnet
resource oci_core_route_table tenant2-privnet-rt {
  provider       = oci.tenant2
  compartment_id = var.compartment_ocid2
  vcn_id         = oci_core_vcn.tenant2-vcn.id
  display_name   = "demo12b_tenant2_privnet_rt"

  route_rules {
    destination       = var.tenant1_cidr_vcn
    network_entity_id = oci_core_drg.tenant1-drg.id
    #OLD: using LPGs instead of DRG (soon deprecated)
    #network_entity_id = oci_core_local_peering_gateway.tenant2-lpg.id
  }
}

# ------ Create a new security list to be used in the new public subnet
resource oci_core_security_list tenant2-pubnet-sl {
  provider       = oci.tenant2
  compartment_id = var.compartment_ocid2
  display_name   = "demo12b_tenant2_pubnet_sl"
  vcn_id         = oci_core_vcn.tenant2-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.tenant2_cidr_vcn
  }
  ingress_security_rules {
    protocol = "all"
    source   = var.tenant1_cidr_vcn
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
resource oci_core_security_list tenant2-privnet-sl {
  provider       = oci.tenant2
  compartment_id = var.compartment_ocid2
  display_name   = "demo12b_tenant2_privnet_sl"
  vcn_id         = oci_core_vcn.tenant2-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.tenant2_cidr_vcn
  }
  ingress_security_rules {
    protocol = "all"
    source   = var.tenant1_cidr_vcn
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
resource oci_core_subnet tenant2-pubnet {
  provider       = oci.tenant2
  cidr_block          = var.tenant2_cidr_pubnet
  display_name        = "demo12b_tenant2_pubnet"
  dns_label           = var.dns_label_public2
  compartment_id      = var.compartment_ocid2
  vcn_id              = oci_core_vcn.tenant2-vcn.id
  route_table_id      = oci_core_route_table.tenant2-pubnet-rt.id
  security_list_ids   = [oci_core_security_list.tenant2-pubnet-sl.id]
  dhcp_options_id     = oci_core_vcn.tenant2-vcn.default_dhcp_options_id
}

# ------ Create a private subnet in the new VCN
resource oci_core_subnet tenant2-privnet {
  provider       = oci.tenant2
  cidr_block          = var.tenant2_cidr_privnet
  display_name        = "demo12b_tenant2_privnet"
  dns_label           = var.dns_label_private2
  compartment_id      = var.compartment_ocid2
  vcn_id              = oci_core_vcn.tenant2-vcn.id
  route_table_id      = oci_core_route_table.tenant2-privnet-rt.id
  security_list_ids   = [oci_core_security_list.tenant2-privnet-sl.id]
  dhcp_options_id     = oci_core_vcn.tenant2-vcn.default_dhcp_options_id
}

#OLD: using LPGs instead of DRG (soon deprecated)
# # ------ Create a Local Peering Gateway (LPG) in the new VCN (ACCEPTOR)
# resource oci_core_local_peering_gateway tenant2-lpg {
#   provider       = oci.tenant2
#   compartment_id = var.compartment_ocid2
#   vcn_id         = oci_core_vcn.tenant2-vcn.id
#   display_name   = "tenant2-lpg"
# }

# ------ Attach DRG in tenant1 to the VCN in tenant2
resource oci_core_drg_attachment tenant2-drg-attachment {
  provider     = oci.tenant2
  drg_id       = oci_core_drg.tenant1-drg.id
  display_name = "attachment_to_drg_in_tenant1"
  network_details {
    type = "VCN"
    id   = oci_core_vcn.tenant2-vcn.id
  }  
}