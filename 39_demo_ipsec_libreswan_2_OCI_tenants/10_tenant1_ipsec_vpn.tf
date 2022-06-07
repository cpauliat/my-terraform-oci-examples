# ======= VPN IPsec connection and related objects

# ------ Generate random string to be used as shared secrets by IPsec tunnels
resource random_string ipsec-shared-secrets {
  count       = 2
  length      = 64
  upper       = true
  min_upper   = 16
  lower       = true
  min_lower   = 16
  numeric     = true
  min_numeric = 2
  special     = false
}

# ------ Create a CPE (customer premise equipment) for LIBRESWAN
resource oci_core_cpe demo39t1-cpe {
  compartment_id = var.tenant1_compartment_ocid
  display_name        = "CPE for tenant2"
  ip_address          = oci_core_instance.demo39t2-libreswan.public_ip
}

# ------ Create an IPsec connection in the DRG
resource oci_core_ipsec demo39t1-ipsec {
  compartment_id = var.tenant1_compartment_ocid
  cpe_id         = oci_core_cpe.demo39t1-cpe.id
  drg_id         = oci_core_drg.demo39t1-drg.id
  display_name   = "IPsec to TENANT2"
  static_routes  = [ var.tenant2_cidr_vcn ]
  cpe_local_identifier      = oci_core_instance.demo39t2-libreswan.private_ip
  cpe_local_identifier_type = "IP_ADDRESS"
}

# ----- Configure the 2 tunnels created in the IPsec connection
data oci_core_ipsec_connection_tunnels demo39t1-ipsec-tunnels {
  ipsec_id = oci_core_ipsec.demo39t1-ipsec.id
}

locals {
  ipsec_id      = oci_core_ipsec.demo39t1-ipsec.id
  tunnel1_id    = data.oci_core_ipsec_connection_tunnels.demo39t1-ipsec-tunnels.ip_sec_connection_tunnels[0].id
  tunnel2_id    = data.oci_core_ipsec_connection_tunnels.demo39t1-ipsec-tunnels.ip_sec_connection_tunnels[1].id
  ipsec_ip1     = data.oci_core_ipsec_connection_tunnels.demo39t1-ipsec-tunnels.ip_sec_connection_tunnels[0].vpn_ip
  ipsec_ip2     = data.oci_core_ipsec_connection_tunnels.demo39t1-ipsec-tunnels.ip_sec_connection_tunnels[1].vpn_ip
  ipsec_secret1 = random_string.ipsec-shared-secrets[0].result
  ipsec_secret2 = random_string.ipsec-shared-secrets[1].result
}

resource oci_core_ipsec_connection_tunnel_management demo39t1-ipsec-tunnel1 {
  ipsec_id      = oci_core_ipsec.demo39t1-ipsec.id
  display_name  = "IPsec tunnel 1"
  tunnel_id     = local.tunnel1_id
  routing       = "STATIC"
  ike_version   = "V1"
  shared_secret = local.ipsec_secret1
}

resource null_resource wait {
  depends_on = [ oci_core_ipsec_connection_tunnel_management.demo39t1-ipsec-tunnel1 ]
  provisioner "local-exec" {
    command = "echo 'Wait between the configuration of the 2 tunnels'; sleep 20"
  }
}

resource oci_core_ipsec_connection_tunnel_management demo39t1-ipsec-tunnel2 {
  depends_on    = [ null_resource.wait ]
  ipsec_id      = oci_core_ipsec.demo39t1-ipsec.id
  display_name  = "IPsec tunnel 2"
  tunnel_id     = local.tunnel2_id
  routing       = "STATIC"
  ike_version   = "V1"
  shared_secret = local.ipsec_secret2
}

