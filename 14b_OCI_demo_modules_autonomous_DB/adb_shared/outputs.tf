# ---- modules outputs
output "password" {
  value = random_string.adb1_admin_password.result
}

output "service_console_url" {
  value = oci_database_autonomous_database.adb1.service_console_url
}