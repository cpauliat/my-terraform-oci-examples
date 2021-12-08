# -------- get the list of available ADs
data oci_identity_availability_domains ADs {
  compartment_id = var.tenancy_ocid
}

# ------ Create a new VCN
resource oci_core_vcn tf-demo22-vcn {
  cidr_blocks    = [ var.cidr_vcn ]
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo22-vcn"
  dns_label      = "tfdemovcn"
}

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway tf-demo22-ig {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo22-internet-gateway"
  vcn_id         = oci_core_vcn.tf-demo22-vcn.id
}

# ------ Create a new Route Table
resource oci_core_route_table tf-demo22-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo22-vcn.id
  display_name   = "tf-demo22-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.tf-demo22-ig.id
  }
}

# ------ Create a new security list to be used in the new subnet
resource oci_core_security_list tf-demo22-subnet1-sl {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo22-subnet1-security-list"
  vcn_id         = oci_core_vcn.tf-demo22-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  # -- not needed as NSG in place for DB sqlnet connection from instance to ADB
  # ingress_security_rules {
  #   protocol = "all"
  #   source   = var.cidr_vcn
  # }
  
  ingress_security_rules {
    protocol = "6" # tcp
    source   = var.authorized_ips
    description = "Allow SSH connection to Linux instance from authorized public IP address(es)"

    tcp_options {
      min = 22 # to allow SSH acccess to Linux instance
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

# ------ Create a public regional subnet 1 in the new VCN
resource oci_core_subnet tf-demo22-public-subnet1 {
  cidr_block          = var.cidr_subnet1
  display_name        = "tf-demo22-public-subnet1"
  dns_label           = "subnet1"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf-demo22-vcn.id
  route_table_id      = oci_core_route_table.tf-demo22-rt.id
  security_list_ids   = [oci_core_security_list.tf-demo22-subnet1-sl.id]
  dhcp_options_id     = oci_core_vcn.tf-demo22-vcn.default_dhcp_options_id
}

# ------ Network security group for Autonomous DB (mandatory when using VCNs with ADBs)

resource oci_core_network_security_group tf-demo22-nsg-adb {
    compartment_id = var.compartment_ocid
    vcn_id         = oci_core_vcn.tf-demo22-vcn.id
    display_name   = "tf-demo22-nsg-adb"
}

resource oci_core_network_security_group_security_rule tf-demo22-nsg-adb-ingress-secrule1 {
    network_security_group_id = oci_core_network_security_group.tf-demo22-nsg-adb.id
    direction                 = "INGRESS"
    protocol                  = "6"       # for ICMP ("1"), TCP ("6"), UDP ("17"), and ICMPv6 ("58")
    description               = "Allow SQLNET connection from VCN subnet"
    source                    = var.cidr_subnet1
    source_type               = "CIDR_BLOCK"
    tcp_options {
        destination_port_range {
            min = "1521"
            max = "1522"
        }
    }
}

resource oci_core_network_security_group_security_rule tf-demo22-nsg-adb-ingress-secrule2 {
    network_security_group_id = oci_core_network_security_group.tf-demo22-nsg-adb.id
    direction                 = "INGRESS"
    protocol                  = "6"       # for ICMP ("1"), TCP ("6"), UDP ("17"), and ICMPv6 ("58")
    description               = "Allow HTTPS connection from VCN subnet"
    source                    = var.cidr_subnet1
    source_type               = "CIDR_BLOCK"
    tcp_options {
        destination_port_range {
            min = "443"
            max = "443"
        }
    }
}