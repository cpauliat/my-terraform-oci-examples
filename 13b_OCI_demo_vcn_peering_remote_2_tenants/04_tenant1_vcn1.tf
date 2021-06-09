# -------- get the list of available ADs
data oci_identity_availability_domains tenant1ADs {
  provider       = oci.tenant1
  compartment_id = var.tenancy_ocid1
}

# ------ Create a new VCN
resource oci_core_vcn tenant1-vcn {
  provider       = oci.tenant1
  cidr_block     = var.tenant1_cidr_vcn
  compartment_id = var.compartment_ocid1
  display_name   = "tf-demo13b-tenant1"
  dns_label      = var.dns_label_tenant1
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway tenant1-ig {
  provider       = oci.tenant1
  compartment_id = var.compartment_ocid1
  display_name   = "demo13b_tenant1_igw"
  vcn_id         = oci_core_vcn.tenant1-vcn.id
}

# ------ Create a new Route Table for the public subnet
resource oci_core_route_table tenant1-pubnet-rt {
  provider       = oci.tenant1
  compartment_id = var.compartment_ocid1
  vcn_id         = oci_core_vcn.tenant1-vcn.id
  display_name   = "demo13b_tenant1_pubnet_rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.tenant1-ig.id
  }

  route_rules {
    destination       = var.tenant2_cidr_vcn
    network_entity_id = oci_core_drg.tenant1-drg.id
  }
}

# ------ Create a new Route Table for the private subnet
resource oci_core_route_table tenant1-privnet-rt {
  provider       = oci.tenant1
  compartment_id = var.compartment_ocid1
  vcn_id         = oci_core_vcn.tenant1-vcn.id
  display_name   = "demo13b_tenant1_privnet_rt"

  route_rules {
    destination       = var.tenant2_cidr_vcn
    network_entity_id = oci_core_drg.tenant1-drg.id
  }
}

# ------ Create a new security list to be used in the new public subnet
resource oci_core_security_list tenant1-pubnet-sl {
  provider       = oci.tenant1
  compartment_id = var.compartment_ocid1
  display_name   = "demo13b_tenant1_pubnet_sl"
  vcn_id         = oci_core_vcn.tenant1-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol    = "all"
    source      = var.tenant1_cidr_vcn
    description = "Allow all traffic from local VCN in current tenant"
  }

  ingress_security_rules {
    protocol    = "all"
    source      = var.tenant2_cidr_vcn
    description = "Allow all traffic from remote VCN in other tenant"
  }

  ingress_security_rules {
    protocol    = "6" # tcp
    source      = var.authorized_ips
    description = "Allow SSH access from authorized public IP address(es)"

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
resource oci_core_security_list tenant1-privnet-sl {
  provider       = oci.tenant1
  compartment_id = var.compartment_ocid1
  display_name   = "demo13b_tenant1_privnet_sl"
  vcn_id         = oci_core_vcn.tenant1-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.tenant1_cidr_privnet
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
resource oci_core_subnet tenant1-pubnet {
  provider            = oci.tenant1
  cidr_block          = var.tenant1_cidr_pubnet
  display_name        = "demo13b_tenant1_pubnet"
  dns_label           = var.dns_label_public1
  compartment_id      = var.compartment_ocid1
  vcn_id              = oci_core_vcn.tenant1-vcn.id
  route_table_id      = oci_core_route_table.tenant1-pubnet-rt.id
  security_list_ids   = [oci_core_security_list.tenant1-pubnet-sl.id]
  dhcp_options_id     = oci_core_vcn.tenant1-vcn.default_dhcp_options_id
}

# ------ Create a private subnet in the new VCN
resource oci_core_subnet tenant1-privnet {
  provider            = oci.tenant1
  cidr_block          = var.tenant1_cidr_privnet
  display_name        = "demo13b_tenant1_privnet"
  dns_label           = var.dns_label_private1
  compartment_id      = var.compartment_ocid1
  vcn_id              = oci_core_vcn.tenant1-vcn.id
  route_table_id      = oci_core_route_table.tenant1-privnet-rt.id
  security_list_ids   = [oci_core_security_list.tenant1-privnet-sl.id]
  dhcp_options_id     = oci_core_vcn.tenant1-vcn.default_dhcp_options_id
}

# ------ Create a Dynamic Routing Gateway (DRG) in the TENANT1 and attach it to the VCN
resource oci_core_drg tenant1-drg {
  provider       = oci.tenant1
  compartment_id = var.compartment_ocid1
  display_name   = "demo13b_tenant1_DRG"
}

resource oci_core_drg_attachment tenant1-drg-attachment {
  provider     = oci.tenant1
  display_name = "attachment_to_local_drg"
  drg_id       = oci_core_drg.tenant1-drg.id
  network_details {
    type = "VCN"
    id   = oci_core_vcn.tenant1-vcn.id
  }  
}

# ------ Enable the remote VCN peering (tenant1 = requestor)
resource oci_core_remote_peering_connection tenant1-requestor {
  provider         = oci.tenant1
  compartment_id   = var.compartment_ocid1
  drg_id           = oci_core_drg.tenant1-drg.id
  display_name     = "tenant1-DRG-RPC"
  peer_id          = oci_core_remote_peering_connection.tenant2-acceptor.id
  peer_region_name = var.region2
}