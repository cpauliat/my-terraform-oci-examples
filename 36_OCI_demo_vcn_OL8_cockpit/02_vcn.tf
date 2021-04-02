# ------ Create a new VCN
resource oci_core_vcn tf-demo36-vcn {
  cidr_block     = var.cidr_vcn
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo36-vcn"
  dns_label      = "demo36"
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway tf-demo36-ig {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo36-internet-gateway"
  vcn_id         = oci_core_vcn.tf-demo36-vcn.id
}

# ------ Create a new Route Table
resource oci_core_route_table tf-demo36-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo36-vcn.id
  display_name   = "tf-demo36-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.tf-demo36-ig.id
  }
}

# ------ Create a new security list to be used in the new subnet
resource oci_core_security_list tf-demo36-subnet1-sl {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo36-subnet1-security-list"
  vcn_id         = oci_core_vcn.tf-demo36-vcn.id

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
  ingress_security_rules {
    protocol = "6" # tcp
    source   = var.authorized_ips

    tcp_options {
      min = 443 # Cockit Web console
      max = 443
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
resource oci_core_subnet tf-demo36-public-subnet1 {
# uncomment the following line to create an AD specific subnet
# availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  cidr_block          = var.cidr_subnet1
  display_name        = "tf-demo36-public-subnet1"
  dns_label           = "subnet1"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf-demo36-vcn.id
  route_table_id      = oci_core_route_table.tf-demo36-rt.id
  security_list_ids   = [oci_core_security_list.tf-demo36-subnet1-sl.id]
  dhcp_options_id     = oci_core_vcn.tf-demo36-vcn.default_dhcp_options_id
}

