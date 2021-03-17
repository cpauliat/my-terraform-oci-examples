# ---- Create the public load balancer
resource oci_load_balancer tf-demo07d-lb {
  shape          = "100Mbps"
  compartment_id = var.compartment_ocid

  subnet_ids = [
    oci_core_subnet.tf-demo07d-public-subnet.id,
  ]

  display_name = "tf-demo07d-public-lb"
}

# ---- Create 2 hostnames
resource oci_load_balancer_hostname tf-demo07d-lb-host1 {
  load_balancer_id = oci_load_balancer.tf-demo07d-lb.id
  hostname         = var.hostname1
  name             = var.hostname1
}

resource oci_load_balancer_hostname tf-demo07d-lb-host2 {
  load_balancer_id = oci_load_balancer.tf-demo07d-lb.id
  hostname         = var.hostname2
  name             = var.hostname2
}

# ---- Create a first backend set with 1 backend server
resource oci_load_balancer_backendset tf-demo07d-lb-bes1 {
  name             = "tf-demo07d-lb-bes1"
  load_balancer_id = oci_load_balancer.tf-demo07d-lb.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}

resource oci_load_balancer_backend tf-demo07d-lb-be1 {
  load_balancer_id = oci_load_balancer.tf-demo07d-lb.id
  backendset_name  = oci_load_balancer_backendset.tf-demo07d-lb-bes1.name
  ip_address       = oci_core_instance.tf-demo07d-ws1.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

# ---- Create a second backend set with 1 backend server
resource oci_load_balancer_backendset tf-demo07d-lb-bes2 {
  name             = "tf-demo07d-lb-bes2"
  load_balancer_id = oci_load_balancer.tf-demo07d-lb.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}

resource oci_load_balancer_backend tf-demo07d-lb-be2 {
  load_balancer_id = oci_load_balancer.tf-demo07d-lb.id
  backendset_name  = oci_load_balancer_backendset.tf-demo07d-lb-bes2.name
  ip_address       = oci_core_instance.tf-demo07d-ws2.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

# ---- Create 2 listeners 
resource oci_load_balancer_listener tf-demo07d-lb-listener1 {
  load_balancer_id         = oci_load_balancer.tf-demo07d-lb.id
  name                     = "tf-demo07d-lb-listener1"
  port                     = 80
  protocol                 = "HTTP"
  hostname_names           = [ oci_load_balancer_hostname.tf-demo07d-lb-host1.name ]
  default_backend_set_name = oci_load_balancer_backendset.tf-demo07d-lb-bes1.name
}

resource oci_load_balancer_listener tf-demo07d-lb-listener2 {
  load_balancer_id         = oci_load_balancer.tf-demo07d-lb.id
  name                     = "tf-demo07d-lb-listener2"
  port                     = 80
  protocol                 = "HTTP"
  hostname_names           = [ oci_load_balancer_hostname.tf-demo07d-lb-host2.name ]
  default_backend_set_name = oci_load_balancer_backendset.tf-demo07d-lb-bes2.name
}
