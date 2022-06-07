# ---- Generate a random string to be used as password MySQL database
resource random_string demo51-mysql-password {
    # must contains at least 2 upper case letters, 2 lower case letters, 2 numbers and 2 special characters
    length      = 16
    upper       = true
    min_upper   = 2
    lower       = true
    min_lower   = 2
    numeric     = true
    min_numeric = 2
    special     = true
    min_special = 2
    override_special = "#+-="   # use only special characters in this list
}

resource oci_mysql_mysql_db_system demo51-mysql1 {
    availability_domain     = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
    compartment_id          = var.compartment_ocid
    display_name            = var.mysql_display_name
    description             = var.mysql_description
    admin_username          = var.mysql_username
    admin_password          = random_string.demo51-mysql-password.result
    shape_name              = var.mysql_shape_name
    subnet_id               = oci_core_subnet.demo51-private-subnet.id
    data_storage_size_in_gb = var.mysql_storage_size_in_gb
    hostname_label          = var.mysql_hostname

    backup_policy {
        is_enabled        = var.mysql_backup_policy_is_enabled
        retention_in_days = var.mysql_backup_policy_retention_in_days
    }

    # See https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/mysql_mysql_db_system
    # for other optional parameters not present here
}