resource oci_load_balancer_load_balancer demo52-lb {
  compartment_id = var.compartment_ocid

  shape          = "flexible"
  shape_details {
    maximum_bandwidth_in_mbps = "100"
    minimum_bandwidth_in_mbps = "10"
  }

  subnet_ids = [
    oci_core_subnet.demo52-public-subnet.id
  ]

  display_name = "demo52-public-lb-ssl-termination"
  reserved_ips { id = var.lb_reserved_public_ip_id }
}

resource oci_load_balancer_backendset demo52-lb-bes {
  name             = "demo52-lb-bes"
  load_balancer_id = oci_load_balancer_load_balancer.demo52-lb.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
    retries             = 1
    interval_ms         = "10000"
  }
}

resource oci_load_balancer_backend demo52-lb-be {
  count            = 2
  load_balancer_id = oci_load_balancer_load_balancer.demo52-lb.id
  backendset_name  = oci_load_balancer_backendset.demo52-lb-bes.name
  ip_address       = oci_core_instance.demo52-ws[count.index].private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

# -- Load Balancer Managed Certificate
resource oci_load_balancer_certificate demo52-lb-certificate {
  count              = var.use_cert_cs == "false" ? 1 : 0  
  certificate_name   = "demo52-cert"
  load_balancer_id   = oci_load_balancer_load_balancer.demo52-lb.id
  ca_certificate     = file(var.file_ca_cert)
  passphrase         = ""
  private_key        = file(var.file_lb_key)
  public_certificate = file(var.file_lb_cert)

  lifecycle {
      create_before_destroy = true
  }
}

# -- Listener using Load Balancer Managed Certificate
resource oci_load_balancer_listener demo52-lb-listener1 {
  depends_on = [ oci_load_balancer_certificate.demo52-lb-certificate ]
  count                    = var.use_cert_cs == "false" ? 1 : 0  
  load_balancer_id         = oci_load_balancer_load_balancer.demo52-lb.id
  name                     = "demo52-lb-listener"
  default_backend_set_name = oci_load_balancer_backendset.demo52-lb-bes.name
  port                     = 443
  protocol                 = "HTTP"
  ssl_configuration {
    certificate_name        = "demo52-cert" 
    verify_peer_certificate = var.verify_peer_certificate
    verify_depth            = 5
    protocols               = [ "TLSv1.2" ]
  }
}

# -- OR Listener using Certificate Service Managed Certificate
resource oci_load_balancer_listener demo52-lb-listener2 {
  count                    = var.use_cert_cs == "true" ? 1 : 0  
  depends_on = [ oci_load_balancer_certificate.demo52-lb-certificate ]
  load_balancer_id         = oci_load_balancer_load_balancer.demo52-lb.id
  name                     = "demo52-lb-listener"
  default_backend_set_name = oci_load_balancer_backendset.demo52-lb-bes.name
  port                     = 443
  protocol                 = "HTTP"
  ssl_configuration {
    certificate_ids         = [ var.oci_cs_cert_id ]
    verify_peer_certificate = var.verify_peer_certificate
    verify_depth            = 5
    protocols               = [ "TLSv1.2" ]
  }
}