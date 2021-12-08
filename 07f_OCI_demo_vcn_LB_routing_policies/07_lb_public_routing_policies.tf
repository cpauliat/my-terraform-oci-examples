# ---- Create the public load balancer
resource oci_load_balancer tf-demo07f-lb {
  compartment_id = var.compartment_ocid
  display_name   = "tf-demo07f-public-lb-routing-policies"
  shape          = "100Mbps"
  # shape          = "flexible"
  # shape_details {
  #     minimum_bandwidth_in_mbps = var.lb_mbps_min
  #     maximum_bandwidth_in_mbps = var.lb_mbps_max
  # }

  subnet_ids = [
    oci_core_subnet.tf-demo07f-public-subnet.id,
  ]
}

# ---- Create 3 backend sets
resource oci_load_balancer_backendset tf-demo07f-lb-bes {
  count            = 3
  name             = "tf-demo07f-lb-bes${count.index+1}"
  load_balancer_id = oci_load_balancer.tf-demo07f-lb.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "TCP"
    retries             = 1
    interval_ms         = "10000"
  }
}

# ---- Create 4 backends (2 per backend set)
resource oci_load_balancer_backend tf-demo07f-lb-be {
  count            = 4
  load_balancer_id = oci_load_balancer.tf-demo07f-lb.id
  backendset_name  = oci_load_balancer_backendset.tf-demo07f-lb-bes[count.index % 2].name
  ip_address       = oci_core_instance.tf-demo07f-ws[count.index].private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource oci_load_balancer_backend tf-demo07f-lb-be-default {
  load_balancer_id = oci_load_balancer.tf-demo07f-lb.id
  backendset_name  = oci_load_balancer_backendset.tf-demo07f-lb-bes[2].name
  ip_address       = oci_core_instance.tf-demo07f-ws[4].private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

# ---- Create a routing policy
resource oci_load_balancer_load_balancer_routing_policy tf-demo07f-lb-rp {
  condition_language_version = "V1"
  load_balancer_id = oci_load_balancer.tf-demo07f-lb.id
  name             = "routing_policy_1"

  rules {
    name      = "routing_rule_1"
    condition = "all(http.request.url.path sw (i '/route1'))"
    actions {
        name             = "FORWARD_TO_BACKENDSET"
        backend_set_name = oci_load_balancer_backendset.tf-demo07f-lb-bes[0].name
    }
  }

  rules {
    name      = "routing_rule_2"
    condition = "all(http.request.url.path sw (i '/route2'))"
    actions {
        name             = "FORWARD_TO_BACKENDSET"
        backend_set_name = oci_load_balancer_backendset.tf-demo07f-lb-bes[1].name
    }
  }
}

# ---- Create 1 listener
resource oci_load_balancer_listener tf-demo07f-lb-listener {
  load_balancer_id         = oci_load_balancer.tf-demo07f-lb.id
  name                     = "tf-demo07f-lb-listener"
  port                     = 80
  protocol                 = "HTTP"
  routing_policy_name      = oci_load_balancer_load_balancer_routing_policy.tf-demo07f-lb-rp.name
  default_backend_set_name = oci_load_balancer_backendset.tf-demo07f-lb-bes[2].name
}
