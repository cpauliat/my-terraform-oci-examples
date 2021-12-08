# -------- get the list of available ADs
data oci_identity_availability_domains ADs {
  compartment_id = var.tenancy_ocid
}

# ------ Create a new VCN
resource oci_core_vcn tf-demo03-vcn {
  cidr_blocks    = [ var.cidr_vcn ]
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo03-vcn"
  dns_label      = "demo03"
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway tf-demo03-ig {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo03-internet-gateway"
  vcn_id         = oci_core_vcn.tf-demo03-vcn.id
}

# ------ Create a new Route Table
resource oci_core_route_table tf-demo03-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo03-vcn.id
  display_name   = "tf-demo03-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.tf-demo03-ig.id
  }
}

# ------ Create a new security list to be used in the new subnet
resource oci_core_security_list tf-demo03-subnet1-sl {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo03-subnet1-security-list"
  vcn_id         = oci_core_vcn.tf-demo03-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.cidr_vcn
  }
  ingress_security_rules {
    protocol = "6" # tcp
    source   = var.authorized_ips

    tcp_options {
      min = 22 # to allow SSH acccess to Linux instance
      max = 22
    }
  }
  ingress_security_rules {
    protocol = "6" # tcp
    source   = var.authorized_ips

    tcp_options {
      min = 3389 # to allow RDP acccess to Windows instance
      max = 3389
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

# ------ Create a public subnet 1 in AD1 in the new VCN
resource oci_core_subnet tf-demo03-public-subnet1 {
# uncomment the following line to create an AD specific subnet
# availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  cidr_block          = var.cidr_subnet1
  display_name        = "tf-demo03-public-subnet1"
  dns_label           = "subnet1"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf-demo03-vcn.id
  route_table_id      = oci_core_route_table.tf-demo03-rt.id
  security_list_ids   = [oci_core_security_list.tf-demo03-subnet1-sl.id]
  dhcp_options_id     = oci_core_vcn.tf-demo03-vcn.default_dhcp_options_id
}

