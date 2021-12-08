# ---- Private DNS configuration to resolve DNS hostname between the 2 remote peered VCNs
data oci_core_vcn_dns_resolver_association resolver1 {
  provider = oci.r1
  vcn_id   = oci_core_vcn.r1-vcn.id
}

resource oci_dns_resolver_endpoint listener-r1 {
  provider           = oci.r1
  is_forwarding      = false
  is_listening       = true
  name               = "region1listener"   # name must match ".*(?:^[a-zA-Z_][a-zA-Z_0-9]*$).*"
  resolver_id        = data.oci_core_vcn_dns_resolver_association.resolver1.dns_resolver_id
  subnet_id          = oci_core_subnet.r1-pubnet.id
  scope              = "PRIVATE"
  endpoint_type      = "VNIC"
  listening_address  = var.dns_listener1
}

resource oci_dns_resolver_endpoint forwarder-r1 {
  provider           = oci.r1
  is_forwarding      = true
  is_listening       = false
  name               = "region1forwarder"    # name must match ".*(?:^[a-zA-Z_][a-zA-Z_0-9]*$).*"
  resolver_id        = data.oci_core_vcn_dns_resolver_association.resolver1.dns_resolver_id
  subnet_id          = oci_core_subnet.r1-pubnet.id
  scope              = "PRIVATE"
  endpoint_type      = "VNIC"
  forwarding_address = var.dns_forwarder1
}

resource oci_dns_resolver resolver1 {
  provider    = oci.r1
  resolver_id = data.oci_core_vcn_dns_resolver_association.resolver1.dns_resolver_id
  scope       = "PRIVATE"
    rules {
      action                 = "FORWARD"
      destination_addresses  = [ var.dns_listener2 ]
      source_endpoint_name   = oci_dns_resolver_endpoint.forwarder-r1.name
      qname_cover_conditions = [ oci_core_vcn.r2-vcn.vcn_domain_name ]
    }
}
