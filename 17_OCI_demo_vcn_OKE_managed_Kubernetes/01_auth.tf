# ---- use variables defined in terraform.tfvars file
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}
variable "AD" {}
variable "authorized_ips" {}
variable "cidr_vcn" {}
variable "cidr_worker" {}
variable "cidr_lb" {}
variable "cidrs_oke" {}
variable "ssh_public_key_file" {}
variable "ssh_private_key_file" {}
variable "oke_cluster_name" {}
variable "oke_cluster_k8s_version" {}
variable "oke_cluster_k8s_dashboard_enabled" {}
variable "oke_cluster_tiller_enabled" {}
variable "oke_k8s_network_config_pods_cidr" {}
variable "oke_k8s_network_config_services_cidr" {}
variable "oke_node_pool_kubernetes_version" {}
variable "oke_node_pool_name" {}
variable "oke_node_pool_node_shape" {}
variable "oke_node_pool_initial_node_labels_key" {}
variable "oke_node_pool_initial_node_labels_value" {}
variable "oke_node_pool_nb_worker_nodes" {}
variable "oke_oracle_linux_version" {}

# ---- provider
provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

