resource "oci_load_balancer" "tf-demo07c-lb" {
  shape          = "100Mbps"
  compartment_id = var.compartment_ocid

  subnet_ids = [
    oci_core_subnet.tf-demo07c-public-subnet.id,
  ]

  display_name = "tf-demo07c-public-lb"
  reserved_ips { id = var.lb_reserved_public_ip_id }
}

resource "oci_load_balancer_backendset" "tf-demo07c-lb-bes" {
  name             = "tf-demo07c-lb-bes"
  load_balancer_id = oci_load_balancer.tf-demo07c-lb.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}

resource "oci_load_balancer_backend" "tf-demo07c-lb-be1" {
  load_balancer_id = oci_load_balancer.tf-demo07c-lb.id
  backendset_name  = oci_load_balancer_backendset.tf-demo07c-lb-bes.name
  ip_address       = oci_core_instance.tf-demo07c-ws1.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource "oci_load_balancer_backend" "tf-demo07c-lb-be2" {
  load_balancer_id = oci_load_balancer.tf-demo07c-lb.id
  backendset_name  = oci_load_balancer_backendset.tf-demo07c-lb-bes.name
  ip_address       = oci_core_instance.tf-demo07c-ws2.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource "oci_load_balancer_certificate" "tf-demo07c-lb-certificate" {
  certificate_name   = "tf-dmo07c-cert"
  load_balancer_id   = oci_load_balancer.tf-demo07c-lb.id
  ca_certificate     = file(var.file_ca_cert)
  passphrase         = ""
  private_key        = file(var.file_lb_key)
  public_certificate = file(var.file_lb_cert)

  lifecycle {
      create_before_destroy = true
  }
}

resource "oci_load_balancer_listener" "tf-demo07c-lb-listener" {
  depends_on = [ oci_load_balancer_certificate.tf-demo07c-lb-certificate ]
  load_balancer_id         = oci_load_balancer.tf-demo07c-lb.id
  name                     = "tf-demo07c-lb-listener"
  default_backend_set_name = oci_load_balancer_backendset.tf-demo07c-lb-bes.name
  port                     = 443
  protocol                 = "HTTP"
  ssl_configuration {
    #certificate_name = "tf-dmo07c-cert" 
    certificate_name = "lb07c-sslforfree"     
  }
}
