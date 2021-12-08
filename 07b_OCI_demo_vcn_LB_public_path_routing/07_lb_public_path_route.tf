# ---- Create the public load balancer
resource oci_load_balancer tf-demo07b-lb {
  shape          = "100Mbps"
  compartment_id = var.compartment_ocid

  subnet_ids = [
    oci_core_subnet.tf-demo07b-public-subnet.id,
  ]

  display_name = "tf-demo07b-public-lb"
}

# ---- Create 2 backend sets
resource oci_load_balancer_backendset tf-demo07b-lb-bes {
  count            = 2
  name             = "tf-demo07b-lb-bes${count.index}"
  load_balancer_id = oci_load_balancer.tf-demo07b-lb.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}

# ---- Create 2 backends (1 per backend set)
resource oci_load_balancer_backend tf-demo07b-lb-be {
  count            = 2
  load_balancer_id = oci_load_balancer.tf-demo07b-lb.id
  backendset_name  = oci_load_balancer_backendset.tf-demo07b-lb-bes[count.index].name
  ip_address       = oci_core_instance.tf-demo07b-ws[count.index].private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

# ---- Create a path route set with 2 path routes
resource oci_load_balancer_path_route_set tf-demo07b-lb-prs {
  load_balancer_id         = oci_load_balancer.tf-demo07b-lb.id
  name                     = "tf-demo07b-lb-path-route-set"

  # 1st path route for application #1 to backend set #1
  path_routes {
    backend_set_name       = oci_load_balancer_backendset.tf-demo07b-lb-bes[0].name
    path                   = "/${var.path_route_websrvs[0]}/"
    path_match_type {
      match_type           = "EXACT_MATCH"
    }
  }

  # 2nd path route for application #2 to backend set #2
  path_routes {
    backend_set_name       = oci_load_balancer_backendset.tf-demo07b-lb-bes[1].name
    path                   = "/${var.path_route_websrvs[1]}/"
    path_match_type {
      match_type           = "EXACT_MATCH"
    }
  }
}

# ---- Create a listener with a path route set
resource oci_load_balancer_listener tf-demo07b-lb-listener {
  load_balancer_id         = oci_load_balancer.tf-demo07b-lb.id
  name                     = "tf-demo07b-lb-listener"
  port                     = 80
  protocol                 = "HTTP"
  path_route_set_name      = oci_load_balancer_path_route_set.tf-demo07b-lb-prs.name
  default_backend_set_name = oci_load_balancer_backendset.tf-demo07b-lb-bes[0].name
}

