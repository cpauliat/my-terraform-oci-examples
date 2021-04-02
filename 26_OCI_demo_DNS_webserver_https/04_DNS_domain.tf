/*resource "oci_dns_zone" "tf-demo26" {
    compartment_id = var.compartment_ocid
    name           = var.dns_domain_name
    zone_type      = "PRIMARY"   # zone content directly from OCI
}
*/

resource oci_dns_record tf-demo26-record1 {
#    zone_name_or_id = oci_dns_zone.tf-demo26.id
    zone_name_or_id = var.dns_domain_name
    domain          = var.dns_hostname
    rtype           = "A"
    rdata           = oci_core_instance.tf-demo26-ws.public_ip
    ttl             = "3600"
}
