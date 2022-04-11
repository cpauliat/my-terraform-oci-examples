# ---- Create the public load balancer
resource oci_load_balancer tf-demo07d-lb {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo07d-public-lb-hostnames"
  shape          = "flexible"
  shape_details {
      minimum_bandwidth_in_mbps = var.lb_mbps_min
      maximum_bandwidth_in_mbps = var.lb_mbps_max
  }

  subnet_ids = [
    oci_core_subnet.tf-demo07d-public-subnet.id,
  ]
}

# ---- Create 2 hostnames
resource oci_load_balancer_hostname tf-demo07d-lb-hosts {
  count            = 2
  load_balancer_id = oci_load_balancer.tf-demo07d-lb.id
  hostname         = var.hostnames[count.index]
  name             = "hostname${count.index+1}"
}

# ---- Create 3 backend sets
resource oci_load_balancer_backendset tf-demo07d-lb-bes {
  count            = 3
  name             = var.lb_bes_names[count.index]   # "tf-demo07d-lb-bes${count.index+1}"
  load_balancer_id = oci_load_balancer.tf-demo07d-lb.id
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

# ---- Create 4 backends (2 per backend set)
resource oci_load_balancer_backend tf-demo07d-lb-be {
  count            = 4
  load_balancer_id = oci_load_balancer.tf-demo07d-lb.id
  backendset_name  = oci_load_balancer_backendset.tf-demo07d-lb-bes[count.index % 2].name
  ip_address       = oci_core_instance.tf-demo07d-ws[count.index].private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

# ---- Create 1 backends for default backend set
resource oci_load_balancer_backend tf-demo07d-lb-be-default {
  load_balancer_id = oci_load_balancer.tf-demo07d-lb.id
  backendset_name  = oci_load_balancer_backendset.tf-demo07d-lb-bes[2].name
  ip_address       = oci_core_instance.tf-demo07d-ws[4].private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}
# ---- Create 2 listeners with virtual hostnames
resource oci_load_balancer_listener tf-demo07d-lb-listener {
  count                    = 2
  load_balancer_id         = oci_load_balancer.tf-demo07d-lb.id
  name                     = var.lb_listeners_names[count.index] #"tf-demo07d-lb-listener${count.index+1}"
  port                     = 80
  protocol                 = "HTTP"
  hostname_names           = [ oci_load_balancer_hostname.tf-demo07d-lb-hosts[count.index].name ]
  default_backend_set_name = oci_load_balancer_backendset.tf-demo07d-lb-bes[count.index].name
}

# ---- Create default listener without virtual hostname
resource oci_load_balancer_listener tf-demo07d-lb-listener-default {
  load_balancer_id         = oci_load_balancer.tf-demo07d-lb.id
  name                     = var.lb_listeners_names[2]
  port                     = 80
  protocol                 = "HTTP"
  default_backend_set_name = oci_load_balancer_backendset.tf-demo07d-lb-bes[2].name
}