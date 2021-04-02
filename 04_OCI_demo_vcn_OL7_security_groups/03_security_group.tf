resource oci_core_network_security_group tf-demo04-nsg1 {
    compartment_id = var.compartment_ocid
    vcn_id         = oci_core_vcn.tf-demo04-vcn.id
    display_name   = "tf-demo04-nsg1"
}

resource oci_core_network_security_group_security_rule tf-demo04-nsg1-ingress-secrule1 {
    network_security_group_id = oci_core_network_security_group.tf-demo04-nsg1.id
    direction                 = "INGRESS"
    protocol                  = "6"       # for ICMP ("1"), TCP ("6"), UDP ("17"), and ICMPv6 ("58")
    description               = "Allow SSH connection only from autorized public IPs"
    source                    = var.authorized_ips
    source_type               = "CIDR_BLOCK"
    tcp_options {
        destination_port_range {
            max = "22"
            min = "22"
        }
    }
}

resource oci_core_network_security_group_security_rule tf-demo04-nsg1-ingress-secrule2 {
    network_security_group_id = oci_core_network_security_group.tf-demo04-nsg1.id
    direction                 = "INGRESS"
    protocol                  = "1"       # for ICMP ("1"), TCP ("6"), UDP ("17"), and ICMPv6 ("58")
    description               = "Needed for Network MTU negotiation: https://docs.cloud.oracle.com/iaas/Content/Network/Troubleshoot/connectionhang.htm"
    source                    = var.authorized_ips
    source_type               = "CIDR_BLOCK"
    icmp_options {
        type = "3"
        code = "4"
    }
}

resource oci_core_network_security_group_security_rule tf-demo04-nsg1-egress-secrule1 {
    # not needed for SSH only as ingress secrule1 is stateful.
    network_security_group_id = oci_core_network_security_group.tf-demo04-nsg1.id
    direction                 = "EGRESS"
    protocol                  = "6"       # for ICMP ("1"), TCP ("6"), UDP ("17"), and ICMPv6 ("58")
    description               = "Allow outgoing traffic"
    destination               = "0.0.0.0/0"
    destination_type          = "CIDR_BLOCK"    
}
