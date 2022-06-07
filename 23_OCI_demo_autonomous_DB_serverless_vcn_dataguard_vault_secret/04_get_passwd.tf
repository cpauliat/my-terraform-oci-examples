# ---- Get password from secret stored in OCI Vault

# -- This does not work in OCI provider 4.68 (secret content not returned)
# data oci_vault_secret tf-demo23-secret-adb-passwd {
#   secret_id = var.adb_password_secret_id
# }

# -- Workaround: use OCI CLI to get secret content
resource local_file tf-demo23-script-getsecret1 {
  content  = "oci --profile ${var.oci_cli_profile} secrets secret-bundle get --secret-id ${var.adb_password_secret_id} --query 'data.\"secret-bundle-content\"' | tr -d '\n' "
  filename = var.script_get_secret1
}

data external tf-demo23-secret1 {
  depends_on = [ local_file.tf-demo23-script-getsecret1 ]
  program = [ "bash", var.script_get_secret1 ]
}

# ---- Generate a random string to be used as password for ADB admin user
resource random_string tf-demo23-adb-password {
  # must contains at least 2 upper case letters, 
  # 2 lower case letters, 2 numbers and 2 special characters
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

# ---- password for ADB from variable, random or OCI vault secret
locals {
  #adb_passwd = var.adb_password  
  #adb_passwd = random_string.tf-demo23-adb-password.result   
  adb_passwd = base64decode(data.external.tf-demo23-secret1.result.content) 
}

# ---- Get auth Token from secret stored in OCI Vault

# # -- This does not work in OCI provider 4.68 (secret content not returned)
# data oci_vault_secret tf-demo23-secret-auth-token {
#   secret_id = var.auth_token_secret_id
# }

# -- Workaround: use OCI CLI to get secret content
resource local_file tf-demo23-script-getsecret2 {
  content  = "oci --profile ${var.oci_cli_profile} secrets secret-bundle get --secret-id ${var.auth_token_secret_id} --query 'data.\"secret-bundle-content\"' | tr -d '\n' "
  filename = var.script_get_secret2
}

data external tf-demo23-secret2 {
  depends_on = [ local_file.tf-demo23-script-getsecret2 ]
  program = [ "bash", var.script_get_secret2 ]
}

locals {
  #auth_token = var.auth_token  
  auth_token = base64decode(data.external.tf-demo23-secret2.result.content) 
}