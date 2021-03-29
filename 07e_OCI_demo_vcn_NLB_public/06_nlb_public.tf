resource oci_network_load_balancer_network_load_balancer tf-demo07e-nlb {
  compartment_id                 = var.compartment_ocid
  display_name                   = "tf-demo07e-public-nlb"
  subnet_id                      = oci_core_subnet.tf-demo07e-public-subnet.id
  is_private                     = "false"
  is_preserve_source_destination = var.nlb_preserve_src_dst
}

resource oci_network_load_balancer_backend_set tf-demo07e-nlb-bes {
  name                     = "tf-demo07e-nlb-bes"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.tf-demo07e-nlb.id
  policy                   = var.nlb_bes_policy
  is_preserve_source       = var.nlb_bes_preserve_src

  health_checker {
    protocol            = "TCP"
    port                = 80
    interval_in_millis  = 10000
    retries             = 2
  }
}

resource oci_network_load_balancer_backend tf-demo07e-nlb-be {
  count                    = 2
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.tf-demo07e-nlb.id
  backend_set_name         = oci_network_load_balancer_backend_set.tf-demo07e-nlb-bes.name
  name                     = "tf-demo07e-nlb-be${count.index+1}"
  port                     = 80
  ip_address               = oci_core_instance.tf-demo07e-ws[count.index].private_ip
  is_backup                = false
  is_drain                 = false
  is_offline               = false
  weight                   = 1
}

resource oci_network_load_balancer_listener tf-demo07e-nlb-listener {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.tf-demo07e-nlb.id
  name                     = "tf-demo07e-nlb-listener"
  default_backend_set_name = oci_network_load_balancer_backend_set.tf-demo07e-nlb-bes.name
  port                     = 80
  protocol                 = "TCP"
}
