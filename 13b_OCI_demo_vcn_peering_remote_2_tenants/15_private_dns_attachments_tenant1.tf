# ---- Private DNS configuration to resolve DNS hostnames between the 2 peered VCNs in different tenants
data oci_core_vcn_dns_resolver_association tenant1-resolver {
  provider = oci.tenant1
  vcn_id   = oci_core_vcn.tenant1-vcn.id
}

resource oci_dns_resolver_endpoint tenant1-listener {
  provider           = oci.tenant1
  is_forwarding      = false
  is_listening       = true
  name               = "tenant1listener"   # name must match ".*(?:^[a-zA-Z_][a-zA-Z_0-9]*$).*"
  resolver_id        = data.oci_core_vcn_dns_resolver_association.tenant1-resolver.dns_resolver_id
  subnet_id          = oci_core_subnet.tenant1-pubnet.id
  scope              = "PRIVATE"
  endpoint_type      = "VNIC"
  listening_address  = var.dns_listener1
}

resource oci_dns_resolver_endpoint tenant1-forwarder {
  provider           = oci.tenant1
  is_forwarding      = true
  is_listening       = false
  name               = "tenant1forwarder"    # name must match ".*(?:^[a-zA-Z_][a-zA-Z_0-9]*$).*"
  resolver_id        = data.oci_core_vcn_dns_resolver_association.tenant1-resolver.dns_resolver_id
  subnet_id          = oci_core_subnet.tenant1-pubnet.id
  scope              = "PRIVATE"
  endpoint_type      = "VNIC"
  forwarding_address = var.dns_forwarder1
}

resource oci_dns_resolver tenant1-resolver {
  provider    = oci.tenant1
  resolver_id = data.oci_core_vcn_dns_resolver_association.tenant1-resolver.dns_resolver_id
  scope       = "PRIVATE"
    rules {
      action                 = "FORWARD"
      destination_addresses  = [ var.dns_listener2 ]
      source_endpoint_name   = oci_dns_resolver_endpoint.tenant1-forwarder.name
      qname_cover_conditions = [ "${var.dns_label_tenant2}.oraclevcn.com" ]
    }
}