resource oci_load_balancer tf-demo07a-lb {
  compartment_id = var.compartment_ocid
  shape          = "flexible"
  shape_details {
    maximum_bandwidth_in_mbps = "100"
    minimum_bandwidth_in_mbps = "10"
  }

  subnet_ids = [
    oci_core_subnet.tf-demo07a-public-subnet.id,
  ]

  display_name = "tf-demo07a-public-lb"
}

resource oci_load_balancer_backendset tf-demo07a-lb-bes {
  name             = "tf-demo07a-lb-bes"
  load_balancer_id = oci_load_balancer.tf-demo07a-lb.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}

resource oci_load_balancer_backend tf-demo07a-lb-be1 {
  load_balancer_id = oci_load_balancer.tf-demo07a-lb.id
  backendset_name  = oci_load_balancer_backendset.tf-demo07a-lb-bes.name
  ip_address       = oci_core_instance.tf-demo07a-ws1.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource oci_load_balancer_backend tf-demo07a-lb-be2 {
  load_balancer_id = oci_load_balancer.tf-demo07a-lb.id
  backendset_name  = oci_load_balancer_backendset.tf-demo07a-lb-bes.name
  ip_address       = oci_core_instance.tf-demo07a-ws2.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource oci_load_balancer_listener tf-demo07a-lb-listener {
  load_balancer_id         = oci_load_balancer.tf-demo07a-lb.id
  name                     = "tf-demo07a-lb-listener"
  default_backend_set_name = oci_load_balancer_backendset.tf-demo07a-lb-bes.name
  port                     = 80
  protocol                 = "HTTP"
}
