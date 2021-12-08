# -------- get the list of available ADs
data oci_identity_availability_domains ADs {
  compartment_id = var.tenancy_ocid
}

# ------ Create a new VCN
resource oci_core_vcn tf-demo10b-vcn {
  cidr_blocks    = [ var.cidr_vcn ]
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo10b-vcn"
  dns_label      = "tfdemovcn"
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway tf-demo10b-ig {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo10b-internet-gateway"
  vcn_id         = oci_core_vcn.tf-demo10b-vcn.id
}

# ------ Create a new Route Table
resource oci_core_route_table tf-demo10b-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo10b-vcn.id
  display_name   = "tf-demo10b-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.tf-demo10b-ig.id
    description       = "single route rule to Internet gateway for all traffic"
  }
}

# ------ Create a new security list to be used in the new subnet
resource oci_core_security_list tf-demo10b-subnet1-sl {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo10b-subnet1-security-list"
  vcn_id         = oci_core_vcn.tf-demo10b-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outgoing traffic"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.cidr_vcn
  }
  ingress_security_rules {
    protocol = "6" # tcp
    source   = var.authorized_ips
    description = "Allow RDP access to Windows instance from authorized public IP address(es)"
    tcp_options {
      min = 3389 
      max = 3389
    }
  }
  ingress_security_rules {
    protocol    = "1" # icmp
    source      = var.authorized_ips
    description = "Needed for MTU. See https://docs.cloud.oracle.com/iaas/Content/Network/Troubleshoot/connectionhang.htm?Highlight=MTU#Path"
    icmp_options {
      type = 3
      code = 4
    }
  }
}

# ------ Create a public subnet 1 in AD1 in the new VCN
resource oci_core_subnet tf-demo10b-public-subnet1 {
# uncomment the following line to create an AD specific subnet
# availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  cidr_block          = var.cidr_subnet1
  display_name        = "tf-demo10b-public-subnet1"
  dns_label           = "subnet1"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf-demo10b-vcn.id
  route_table_id      = oci_core_route_table.tf-demo10b-rt.id
  security_list_ids   = [oci_core_security_list.tf-demo10b-subnet1-sl.id]
  dhcp_options_id     = oci_core_vcn.tf-demo10b-vcn.default_dhcp_options_id
}

