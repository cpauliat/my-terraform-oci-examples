# -------- get the list of available ADs
data oci_identity_availability_domains ADs {
  compartment_id = var.tenancy_ocid
}

# ------ Create a new VCN
resource oci_core_vcn tf-oow2019-hol1512-vcn {
  cidr_block     = var.cidr_vcn
  compartment_id = var.compartment_ocid
  display_name   = "HOL1512 vcn"
  dns_label      = "hol1512vcn"
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway tf-oow2019-hol1512-ig {
  compartment_id = var.compartment_ocid
  display_name   = "HOL1512 ig"
  vcn_id         = oci_core_vcn.tf-oow2019-hol1512-vcn.id
}

# ------ Create a new Route Table
resource oci_core_route_table tf-oow2019-hol1512-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-oow2019-hol1512-vcn.id
  display_name   = "HOL1512 route table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.tf-oow2019-hol1512-ig.id
  }
}

# ------ Create a new security list to be used in the new subnet
resource oci_core_security_list tf-oow2019-hol1512-subnet1-sl {
  compartment_id = var.compartment_ocid
  display_name   = "HOL1512 seclist"
  vcn_id         = oci_core_vcn.tf-oow2019-hol1512-vcn.id

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
      min = 80 # to allow HTTP acccess
      max = 80
    }
  }
}

# ------ Create a public subnet 1 in AD1 in the new VCN
resource oci_core_subnet tf-oow2019-hol1512-public-subnet1 {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  cidr_block          = var.cidr_subnet1
  display_name        = "HOL1512 public subnet 1"
  dns_label           = "subnet1"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf-oow2019-hol1512-vcn.id
  route_table_id      = oci_core_route_table.tf-oow2019-hol1512-rt.id
  security_list_ids   = [oci_core_security_list.tf-oow2019-hol1512-subnet1-sl.id]
  dhcp_options_id     = oci_core_vcn.tf-oow2019-hol1512-vcn.default_dhcp_options_id
}
