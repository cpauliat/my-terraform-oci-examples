# -------- get the list of available ADs
data oci_identity_availability_domains ADs {
  compartment_id = var.tenancy_ocid
}

# ------ Create a new VCN
resource oci_core_vcn demo35b-vcn {
  cidr_blocks    = [ var.cidr_vcn ]
  compartment_id = var.compartment_ocid
  display_name   = "demo35b-vcn"
  dns_label      = "demo35b"
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway demo35b-ig {
  compartment_id = var.compartment_ocid
  display_name   = "internet gateway"
  vcn_id         = oci_core_vcn.demo35b-vcn.id
}

# ------ Create a new Route Table
resource oci_core_route_table demo35b-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.demo35b-vcn.id
  display_name   = "demo35b route table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.demo35b-ig.id
  }
}

# ------ Create a new security list 
resource oci_core_security_list demo35b-sl {
  compartment_id = var.compartment_ocid
  display_name   = "demo35b subnet security list"
  vcn_id         = oci_core_vcn.demo35b-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.cidr_vcn
  }
}

# ------ Create a public regional subnet 
resource oci_core_subnet demo35b-subnet1 {
  cidr_block          = var.cidr_subnet1
  display_name        = "subnet1"
  dns_label           = "subnet1"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.demo35b-vcn.id
  route_table_id      = oci_core_route_table.demo35b-rt.id
  security_list_ids   = [oci_core_security_list.demo35b-sl.id]
  dhcp_options_id     = oci_core_vcn.demo35b-vcn.default_dhcp_options_id
}

# ------ Create a network security group to allow SSH connections from specific public IPs 
resource oci_core_network_security_group demo35b {
    compartment_id = var.compartment_ocid
    vcn_id         = oci_core_vcn.demo35b-vcn.id
    display_name   = "demo35b"
}

resource oci_core_network_security_group_security_rule demo35b-secrule1 {
    network_security_group_id = oci_core_network_security_group.demo35b.id
    direction                 = "INGRESS"
    protocol                  = "6"       # for ICMP ("1"), TCP ("6"), UDP ("17"), and ICMPv6 ("58")
    description               = "Allow SSH connection from C. Pauliat's public IP"
    source                    = var.authorized_ips
    source_type               = "CIDR_BLOCK"
    tcp_options {
        destination_port_range {
            max = "22"
            min = "22"
        }
    }
}

resource oci_core_network_security_group_security_rule demo35b-secrule2 {
    network_security_group_id = oci_core_network_security_group.demo35b.id
    direction                 = "INGRESS"
    protocol                  = "6"       # for ICMP ("1"), TCP ("6"), UDP ("17"), and ICMPv6 ("58")
    description               = "Allow Remote Desktop connection to Nice DCV on port HTTPS 8443"
    source                    = var.authorized_ips
    source_type               = "CIDR_BLOCK"
    tcp_options {
        destination_port_range {
            max = "8443"
            min = "8443"
        }
    }
}