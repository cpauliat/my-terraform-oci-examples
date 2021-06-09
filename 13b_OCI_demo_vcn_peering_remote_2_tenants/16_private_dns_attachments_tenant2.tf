# ---- Private DNS configuration to resolve DNS hostnames between the 2 peered VCNs in different tenants
data oci_core_vcn_dns_resolver_association tenant2-resolver {
  provider = oci.tenant2
  vcn_id   = oci_core_vcn.tenant2-vcn.id
}

resource oci_dns_resolver_endpoint tenant2-listener {
  provider           = oci.tenant2
  is_forwarding      = false
  is_listening       = true
  name               = "tenant2listener"   # name must match ".*(?:^[a-zA-Z_][a-zA-Z_0-9]*$).*"
  resolver_id        = data.oci_core_vcn_dns_resolver_association.tenant2-resolver.dns_resolver_id
  subnet_id          = oci_core_subnet.tenant2-pubnet.id
  scope              = "PRIVATE"
  endpoint_type      = "VNIC"
  listening_address  = var.dns_listener2
}

resource oci_dns_resolver_endpoint tenant2-forwarder {
  provider           = oci.tenant2
  is_forwarding      = true
  is_listening       = false
  name               = "tenant2forwarder"    # name must match ".*(?:^[a-zA-Z_][a-zA-Z_0-9]*$).*"
  resolver_id        = data.oci_core_vcn_dns_resolver_association.tenant2-resolver.dns_resolver_id
  subnet_id          = oci_core_subnet.tenant2-pubnet.id
  scope              = "PRIVATE"
  endpoint_type      = "VNIC"
  forwarding_address = var.dns_forwarder2
}

resource oci_dns_resolver tenant2-resolver {
  provider    = oci.tenant2
  resolver_id = data.oci_core_vcn_dns_resolver_association.tenant2-resolver.dns_resolver_id
  scope       = "PRIVATE"
    rules {
      action                 = "FORWARD"
      destination_addresses  = [ var.dns_listener1 ]
      source_endpoint_name   = oci_dns_resolver_endpoint.tenant2-forwarder.name
      qname_cover_conditions = [ "${var.dns_label_tenant1}.oraclevcn.com" ]
    }
}