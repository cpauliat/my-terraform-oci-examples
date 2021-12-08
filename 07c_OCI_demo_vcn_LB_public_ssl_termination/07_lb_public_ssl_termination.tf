resource oci_load_balancer_load_balancer tf-demo07c-lb {
  compartment_id = var.compartment_ocid

  shape          = "flexible"
  shape_details {
    maximum_bandwidth_in_mbps = "100"
    minimum_bandwidth_in_mbps = "10"
  }

  subnet_ids = [
    oci_core_subnet.tf-demo07c-public-subnet.id
  ]

  display_name = "tf-demo07c-public-lb-ssl-termination"
  reserved_ips { id = var.lb_reserved_public_ip_id }
}

resource oci_load_balancer_backendset tf-demo07c-lb-bes {
  name             = "tf-demo07c-lb-bes"
  load_balancer_id = oci_load_balancer_load_balancer.tf-demo07c-lb.id
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

resource oci_load_balancer_backend tf-demo07c-lb-be {
  count            = 2
  load_balancer_id = oci_load_balancer_load_balancer.tf-demo07c-lb.id
  backendset_name  = oci_load_balancer_backendset.tf-demo07c-lb-bes.name
  ip_address       = oci_core_instance.tf-demo07c-ws[count.index].private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

# -- Load Balancer Managed Certificate
resource oci_load_balancer_certificate tf-demo07c-lb-certificate {
  count              = var.use_cert_cs == "false" ? 1 : 0  
  certificate_name   = "tf-demo07c-cert"
  load_balancer_id   = oci_load_balancer_load_balancer.tf-demo07c-lb.id
  ca_certificate     = file(var.file_ca_cert)
  passphrase         = ""
  private_key        = file(var.file_lb_key)
  public_certificate = file(var.file_lb_cert)

  lifecycle {
      create_before_destroy = true
  }
}

# -- Listener using Load Balancer Managed Certificate
resource oci_load_balancer_listener tf-demo07c-lb-listener1 {
  depends_on = [ oci_load_balancer_certificate.tf-demo07c-lb-certificate ]
  count                    = var.use_cert_cs == "false" ? 1 : 0  
  load_balancer_id         = oci_load_balancer_load_balancer.tf-demo07c-lb.id
  name                     = "tf-demo07c-lb-listener"
  default_backend_set_name = oci_load_balancer_backendset.tf-demo07c-lb-bes.name
  port                     = 443
  protocol                 = "HTTP"
  ssl_configuration {
    certificate_name        = "tf-demo07c-cert" 
    verify_peer_certificate = var.verify_peer_certificate
    verify_depth            = 5
    protocols               = [ "TLSv1.2" ]
  }
}

# -- OR Listener using Certificate Service Managed Certificate
resource oci_load_balancer_listener tf-demo07c-lb-listener2 {
  count                    = var.use_cert_cs == "true" ? 1 : 0  
  depends_on = [ oci_load_balancer_certificate.tf-demo07c-lb-certificate ]
  load_balancer_id         = oci_load_balancer_load_balancer.tf-demo07c-lb.id
  name                     = "tf-demo07c-lb-listener"
  default_backend_set_name = oci_load_balancer_backendset.tf-demo07c-lb-bes.name
  port                     = 443
  protocol                 = "HTTP"
  ssl_configuration {
    certificate_ids         = [ var.oci_cs_cert_id ]
    verify_peer_certificate = var.verify_peer_certificate
    verify_depth            = 5
    protocols               = [ "TLSv1.2" ]
  }
}