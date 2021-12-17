resource oci_waf_web_app_firewall_policy demo52 {
    compartment_id = var.compartment_ocid
    display_name   = "demo52"

    actions {
        name = "block_access_from_your_country"
        type = "RETURN_HTTP_RESPONSE"
        body {
            text = "<H1 style=\"text-align: center;\"><br>Access blocked by OCI WAF !<br>Access is not authorized from your country.</H1>"
            type = "STATIC_TEXT"
        }
        code = "401"
        headers {
            name = "source_country"
            value = "unauthorized"
        }
    }

    actions {
        name = "allow_access"
        type = "ALLOW"
        code = "200"
    }

    # Block access except from authorized countries
    request_access_control {
        default_action_name = "block_access_from_your_country"
        rules {
            action_name        = "allow_access"
            name               = "authorized_access_from_those_countries"
            type               = "ACCESS_CONTROL"
            condition          = "i_contains(${var.allowed_countries}, connection.source.geo.countryCode)"
            condition_language = "JMESPATH"
        }
    }

    # response_access_control {

    #     #Optional
    #     rules {
    #         #Required
    #         action_name = var.web_app_firewall_policy_response_access_control_rules_action_name
    #         name = var.web_app_firewall_policy_response_access_control_rules_name
    #         type = var.web_app_firewall_policy_response_access_control_rules_type

    #         #Optional
    #         condition = var.web_app_firewall_policy_response_access_control_rules_condition
    #         condition_language = var.web_app_firewall_policy_response_access_control_rules_condition_language
    #     }
    # }

    # request_protection {

    #     #Optional
    #     rules {
    #         #Required
    #         action_name = var.web_app_firewall_policy_request_protection_rules_action_name
    #         name = var.web_app_firewall_policy_request_protection_rules_name
    #         protection_capabilities {
    #             #Required
    #             key = var.web_app_firewall_policy_request_protection_rules_protection_capabilities_key
    #             version = var.web_app_firewall_policy_request_protection_rules_protection_capabilities_version

    #             #Optional
    #             action_name = var.web_app_firewall_policy_request_protection_rules_protection_capabilities_action_name
    #             collaborative_action_threshold = var.web_app_firewall_policy_request_protection_rules_protection_capabilities_collaborative_action_threshold
    #             collaborative_weights {
    #                 #Required
    #                 key = var.web_app_firewall_policy_request_protection_rules_protection_capabilities_collaborative_weights_key
    #                 weight = var.web_app_firewall_policy_request_protection_rules_protection_capabilities_collaborative_weights_weight
    #             }
    #             exclusions {

    #                 #Optional
    #                 args = var.web_app_firewall_policy_request_protection_rules_protection_capabilities_exclusions_args
    #                 request_cookies = var.web_app_firewall_policy_request_protection_rules_protection_capabilities_exclusions_request_cookies
    #             }
    #         }
    #         type = var.web_app_firewall_policy_request_protection_rules_type

    #         #Optional
    #         condition = var.web_app_firewall_policy_request_protection_rules_condition
    #         condition_language = var.web_app_firewall_policy_request_protection_rules_condition_language
    #         protection_capability_settings {

    #             #Optional
    #             allowed_http_methods = var.web_app_firewall_policy_request_protection_rules_protection_capability_settings_allowed_http_methods
    #             max_http_request_header_length = var.web_app_firewall_policy_request_protection_rules_protection_capability_settings_max_http_request_header_length
    #             max_http_request_headers = var.web_app_firewall_policy_request_protection_rules_protection_capability_settings_max_http_request_headers
    #             max_number_of_arguments = var.web_app_firewall_policy_request_protection_rules_protection_capability_settings_max_number_of_arguments
    #             max_single_argument_length = var.web_app_firewall_policy_request_protection_rules_protection_capability_settings_max_single_argument_length
    #             max_total_argument_length = var.web_app_firewall_policy_request_protection_rules_protection_capability_settings_max_total_argument_length
    #         }
    #     }
    # }

    # response_protection {

    #     #Optional
    #     rules {
    #         #Required
    #         action_name = var.web_app_firewall_policy_response_protection_rules_action_name
    #         name = var.web_app_firewall_policy_response_protection_rules_name
    #         protection_capabilities {
    #             #Required
    #             key = var.web_app_firewall_policy_response_protection_rules_protection_capabilities_key
    #             version = var.web_app_firewall_policy_response_protection_rules_protection_capabilities_version

    #             #Optional
    #             action_name = var.web_app_firewall_policy_response_protection_rules_protection_capabilities_action_name
    #             collaborative_action_threshold = var.web_app_firewall_policy_response_protection_rules_protection_capabilities_collaborative_action_threshold
    #             collaborative_weights {
    #                 #Required
    #                 key = var.web_app_firewall_policy_response_protection_rules_protection_capabilities_collaborative_weights_key
    #                 weight = var.web_app_firewall_policy_response_protection_rules_protection_capabilities_collaborative_weights_weight
    #             }
    #             exclusions {

    #                 #Optional
    #                 args = var.web_app_firewall_policy_response_protection_rules_protection_capabilities_exclusions_args
    #                 request_cookies = var.web_app_firewall_policy_response_protection_rules_protection_capabilities_exclusions_request_cookies
    #             }
    #         }
    #         type = var.web_app_firewall_policy_response_protection_rules_type

    #         #Optional
    #         condition = var.web_app_firewall_policy_response_protection_rules_condition
    #         condition_language = var.web_app_firewall_policy_response_protection_rules_condition_language
    #         protection_capability_settings {

    #             #Optional
    #             allowed_http_methods = var.web_app_firewall_policy_response_protection_rules_protection_capability_settings_allowed_http_methods
    #             max_http_request_header_length = var.web_app_firewall_policy_response_protection_rules_protection_capability_settings_max_http_request_header_length
    #             max_http_request_headers = var.web_app_firewall_policy_response_protection_rules_protection_capability_settings_max_http_request_headers
    #             max_number_of_arguments = var.web_app_firewall_policy_response_protection_rules_protection_capability_settings_max_number_of_arguments
    #             max_single_argument_length = var.web_app_firewall_policy_response_protection_rules_protection_capability_settings_max_single_argument_length
    #             max_total_argument_length = var.web_app_firewall_policy_response_protection_rules_protection_capability_settings_max_total_argument_length
    #         }
    #     }
    # }

    # request_rate_limiting {

    #     #Optional
    #     rules {
    #         #Required
    #         action_name = var.web_app_firewall_policy_request_rate_limiting_rules_action_name
    #         configurations {
    #             #Required
    #             period_in_seconds = var.web_app_firewall_policy_request_rate_limiting_rules_configurations_period_in_seconds
    #             requests_limit = var.web_app_firewall_policy_request_rate_limiting_rules_configurations_requests_limit

    #             #Optional
    #             action_duration_in_seconds = var.web_app_firewall_policy_request_rate_limiting_rules_configurations_action_duration_in_seconds
    #         }
    #         name = var.web_app_firewall_policy_request_rate_limiting_rules_name
    #         type = var.web_app_firewall_policy_request_rate_limiting_rules_type

    #         #Optional
    #         condition = var.web_app_firewall_policy_request_rate_limiting_rules_condition
    #         condition_language = var.web_app_firewall_policy_request_rate_limiting_rules_condition_language
    #     }
    # }

    #system_tags = var.web_app_firewall_policy_system_tags
}

# associate the WAF policy to the OCI load balancer
resource oci_waf_web_app_firewall demo52 {
    compartment_id             = var.compartment_ocid
    display_name               = "demo52"
    backend_type               = "LOAD_BALANCER"
    load_balancer_id           = oci_load_balancer_load_balancer.demo52-lb.id
    web_app_firewall_policy_id = oci_waf_web_app_firewall_policy.demo52.id
}