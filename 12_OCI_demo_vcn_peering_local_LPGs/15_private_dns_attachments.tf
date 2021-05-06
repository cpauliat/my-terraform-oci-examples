resource null_resource wait_1_minute {
  provisioner "local-exec" {
    command = "sleep 60"
  }
}


# ---- Attach the DNS private view for VCN1 to VCN2 DNS resolver to be able to resolve VCN1 hostnames in VCN2
data oci_core_vcn_dns_resolver_association vcn2 {
  depends_on     = [ null_resource.wait_1_minute ]    # Wait at 1 minute for DNS resolver to be ready
  vcn_id = oci_core_vcn.vcn2-vcn.id
}

data oci_dns_views vcn1 {
  depends_on     = [ null_resource.wait_1_minute ]    # Wait at 1 minute for DNS private view to be ready
  compartment_id = var.compartment_ocid
  scope          = "PRIVATE"
  display_name   = "tf-demo12-vcn1"
}

resource oci_dns_resolver vcn2-dns-resolver {
  attached_views { view_id = data.oci_dns_views.vcn1.views[0].id }
  display_name = "resolver-for-VCN1"
  resolver_id  = data.oci_core_vcn_dns_resolver_association.vcn2.dns_resolver_id
  scope        = "PRIVATE"
}

# ---- Attach the DNS private view for VCN2 to VCN1 DNS resolver to be able to resolve VCN2 hostnames in VCN1
data oci_core_vcn_dns_resolver_association vcn1 {
  depends_on     = [ null_resource.wait_1_minute ]    # Wait at 1 minute for DNS resolver to be ready
  vcn_id = oci_core_vcn.vcn1-vcn.id
}

data oci_dns_views vcn2 {
  depends_on     = [ null_resource.wait_1_minute ]    # Wait at 1 minute for DNS private view to be ready
  compartment_id = var.compartment_ocid
  scope          = "PRIVATE"
  display_name   = "tf-demo12-vcn2"
}

resource oci_dns_resolver vcn1-dns-resolver {
  attached_views { view_id = data.oci_dns_views.vcn2.views[0].id }
  display_name = "resolver-for-VCN2"
  resolver_id  = data.oci_core_vcn_dns_resolver_association.vcn1.dns_resolver_id
  scope        = "PRIVATE"
}
