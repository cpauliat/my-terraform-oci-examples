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
resource oci_load_balancer_hostname tf-demo07d-lb-hosts {
  count            = 2
  load_balancer_id = oci_load_balancer.tf-demo07d-lb.id
  hostname         = "hostname${count.index+1}"
  name             = var.hostnames[count.index]
}

# ---- Create 2 backend sets
resource oci_load_balancer_backendset tf-demo07d-lb-bes {
  count            = 2
  name             = "tf-demo07d-lb-bes${count.index+1}"
  load_balancer_id = oci_load_balancer.tf-demo07d-lb.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}

# ---- Create 2 backends (1 per backend set)
resource oci_load_balancer_backend tf-demo07d-lb-be {
  count            = 2
  load_balancer_id = oci_load_balancer.tf-demo07d-lb.id
  backendset_name  = oci_load_balancer_backendset.tf-demo07d-lb-bes[count.index].name
  ip_address       = oci_core_instance.tf-demo07d-ws[count.index].private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

# ---- Create 2 listeners 
resource oci_load_balancer_listener tf-demo07d-lb-listener {
  count                    = 2
  load_balancer_id         = oci_load_balancer.tf-demo07d-lb.id
  name                     = "tf-demo07d-lb-listener${count.index+1}"
  port                     = 80
  protocol                 = "HTTP"
  hostname_names           = [ oci_load_balancer_hostname.tf-demo07d-lb-hosts[count.index].name ]
  default_backend_set_name = oci_load_balancer_backendset.tf-demo07d-lb-bes[count.index].name
}
