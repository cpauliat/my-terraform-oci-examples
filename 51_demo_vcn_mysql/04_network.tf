# ------ Create a new VCN
resource oci_core_vcn demo51-vcn {
    cidr_blocks    = [ var.cidr_vcn ]
    compartment_id = var.compartment_ocid
    display_name   = "demo51-vcn"
    dns_label      = var.dns_label_vcn
}

# ======== Objects for public subnet

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway demo51-public-ig {
    compartment_id = var.compartment_ocid
    display_name   = "demo51-public-ig"
    vcn_id         = oci_core_vcn.demo51-vcn.id
}

# ------ Create a new Route Table
resource oci_core_route_table demo51-public-rt {
    compartment_id = var.compartment_ocid
    vcn_id         = oci_core_vcn.demo51-vcn.id
    display_name   = "demo51-public-rt"

    route_rules {
        destination       = "0.0.0.0/0"
        network_entity_id = oci_core_internet_gateway.demo51-public-ig.id
        description       = "Default route to Internet Gateway"
    }
}

# ------ Create a new security list to be used in the public subnet
resource oci_core_security_list demo51-public-subnet-sl {
    compartment_id = var.compartment_ocid
    display_name   = "demo51-public-subnet-seclist"
    vcn_id         = oci_core_vcn.demo51-vcn.id

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

# ------ Create a public regional subnet in the new VCN
resource oci_core_subnet demo51-public-subnet {
    cidr_block          = var.cidr_subnet_public
    display_name        = "demo51-public-subnet"
    dns_label           = var.dns_label_public
    compartment_id      = var.compartment_ocid
    vcn_id              = oci_core_vcn.demo51-vcn.id
    route_table_id      = oci_core_route_table.demo51-public-rt.id
    security_list_ids   = [oci_core_security_list.demo51-public-subnet-sl.id]
    dhcp_options_id     = oci_core_vcn.demo51-vcn.default_dhcp_options_id
}

# ======== Objects for private subnet

# ------ Create a new Services Gategay
data oci_core_services services {
    filter {
        name   = "name"
        values = ["All .* Services In Oracle Services Network"]
        regex  = true
    }
}

resource oci_core_service_gateway demo51-private-sgw {
    compartment_id = var.compartment_ocid
    vcn_id         = oci_core_vcn.demo51-vcn.id
    services {
        service_id = lookup(data.oci_core_services.services.services[0], "id")
    }
    display_name   = "demo51-private-sgw"
}

# ------ Create a NAT gateway
resource oci_core_nat_gateway demo51-private-natgw {
    compartment_id = var.compartment_ocid
    vcn_id         = oci_core_vcn.demo51-vcn.id
    display_name   = "demo51-private-natgw"
}

# ------ Create a new Route Table
resource oci_core_route_table demo51-private-rt {
    compartment_id = var.compartment_ocid
    vcn_id         = oci_core_vcn.demo51-vcn.id
    display_name   = "demo51-private-rt"

    route_rules {
        destination       = "0.0.0.0/0"
        network_entity_id = oci_core_nat_gateway.demo51-private-natgw.id
        description       = "Default route to NAT Gateway"
    }

    route_rules {
        destination       = lookup(data.oci_core_services.services.services[0], "cidr_block")
        destination_type  = "SERVICE_CIDR_BLOCK"
        network_entity_id = oci_core_service_gateway.demo51-private-sgw.id
        description       = "Route to some Oracle cloud Services from private subnet"
    }
}

# ------ Create a new security list to be used in the new subnet
resource oci_core_security_list demo51-private-subnet-sl {
    compartment_id = var.compartment_ocid
    display_name   = "demo51-private-subnet-seclist"
    vcn_id         = oci_core_vcn.demo51-vcn.id

    egress_security_rules {
        protocol    = "all"
        destination = "0.0.0.0/0"
    }

    ingress_security_rules {
        protocol = "all"
        source   = var.cidr_vcn
    }
}

# ------ Create a private regional subnet in the new VCN
resource oci_core_subnet demo51-private-subnet {
    cidr_block          = var.cidr_subnet_private
    display_name        = "demo51-private-subnet"
    dns_label           = var.dns_label_private
    compartment_id      = var.compartment_ocid
    vcn_id              = oci_core_vcn.demo51-vcn.id
    route_table_id      = oci_core_route_table.demo51-private-rt.id
    security_list_ids   = [oci_core_security_list.demo51-private-subnet-sl.id]
    dhcp_options_id     = oci_core_vcn.demo51-vcn.default_dhcp_options_id
    prohibit_public_ip_on_vnic = true
}

