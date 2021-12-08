# ---- Private DNS configuration to resolve DNS hostname between the 2 remote peered VCNs
data oci_core_vcn_dns_resolver_association resolver2 {
  provider = oci.r2
  vcn_id   = oci_core_vcn.r2-vcn.id
}

resource oci_dns_resolver_endpoint listener-r2 {
  provider           = oci.r2
  is_forwarding      = false
  is_listening       = true
  name               = "region2listener"   # name must match ".*(?:^[a-zA-Z_][a-zA-Z_0-9]*$).*"
  resolver_id        = data.oci_core_vcn_dns_resolver_association.resolver2.dns_resolver_id
  subnet_id          = oci_core_subnet.r2-pubnet.id
  scope              = "PRIVATE"
  endpoint_type      = "VNIC"
  listening_address  = var.dns_listener2
}

resource oci_dns_resolver_endpoint forwarder-r2 {
  provider           = oci.r2
  is_forwarding      = true
  is_listening       = false
  name               = "region2forwarder"   # name must match ".*(?:^[a-zA-Z_][a-zA-Z_0-9]*$).*"
  resolver_id        = data.oci_core_vcn_dns_resolver_association.resolver2.dns_resolver_id
  subnet_id          = oci_core_subnet.r2-pubnet.id
  scope              = "PRIVATE"
  endpoint_type      = "VNIC"
  forwarding_address = var.dns_forwarder2
}

resource oci_dns_resolver resolver2 {
  provider    = oci.r2
  resolver_id = data.oci_core_vcn_dns_resolver_association.resolver2.dns_resolver_id
  scope       = "PRIVATE"
    rules {
      action                 = "FORWARD"
      destination_addresses  = [ var.dns_listener1 ]
      source_endpoint_name   = oci_dns_resolver_endpoint.forwarder-r2.name
      qname_cover_conditions = [ oci_core_vcn.r1-vcn.vcn_domain_name ]
    }
}
