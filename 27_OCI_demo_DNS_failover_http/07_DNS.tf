resource oci_dns_zone tf-demo27 {
    compartment_id = var.compartment_ocid
    name           = var.dns_domain_name
    zone_type      = "PRIMARY"   # zone content directly from OCI
}

resource oci_health_checks_http_monitor tf_demo27 {
  compartment_id = var.compartment_ocid
  display_name = "tf-demo27-health-check"

  interval_in_seconds = "10"
  is_enabled          = "true"
  method              = "HEAD"
  path                = "/"
  port                = "80"
  protocol            = "HTTP"
  targets = [
    oci_core_instance.tf-demo27-ws1.public_ip,
    oci_core_instance.tf-demo27-ws2.public_ip
  ]
  timeout_in_seconds  = "10"
  vantage_point_names = [
    "azr-sat",
    "goo-chs",
    "aws-dub",
  ]
}

resource oci_dns_steering_policy tf_demo27 {
    compartment_id = var.compartment_ocid
    display_name   = "tf_demo27_failover"
    template       = "FAILOVER"
    ttl            = "30"      # seconds

    answers {
        is_disabled = "false"
        name        = "ws1"
        pool        = "ws1"
        rdata       = oci_core_instance.tf-demo27-ws1.public_ip
        rtype       = "A"
    }

    answers {
        is_disabled = "false"
        name        = "ws2"
        pool        = "ws2"
        rdata       = oci_core_instance.tf-demo27-ws2.public_ip
        rtype       = "A"
    }

    health_check_monitor_id = oci_health_checks_http_monitor.tf_demo27.id

    rules {
        rule_type   = "FILTER"
        description = "Removes disabled answers."
        default_answer_data {
            answer_condition = "answer.isDisabled != true"
            should_keep      = "true"
        }
    }

    rules {
        rule_type   = "HEALTH"
        description = "Removes unhealthy answers."
    }

    rules {
        rule_type = "PRIORITY"
        default_answer_data {
            answer_condition = "answer.pool == 'ws1'"
            value = "0"
        }
    
        default_answer_data {
            answer_condition = "answer.pool == 'ws2'"
            value = "1"
        }
    }

    rules {
        rule_type = "LIMIT"
        default_count = "1"
    }

}

resource oci_dns_steering_policy_attachment tf_demo27 {
  display_name       = "tf_demo27"
  domain_name        = var.dns_hostname
  steering_policy_id = oci_dns_steering_policy.tf_demo27.id
  zone_id            = oci_dns_zone.tf-demo27.id
}

