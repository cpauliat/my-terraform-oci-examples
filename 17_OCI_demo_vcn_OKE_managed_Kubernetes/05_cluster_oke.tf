# --------- Create an OKE cluster
resource oci_containerengine_cluster demo17-oke {
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.oke_cluster_k8s_version
  name               = var.oke_cluster_name
  vcn_id             = oci_core_vcn.demo17-vcn.id

  endpoint_config {
    is_public_ip_enabled = "true"
    subnet_id            = oci_core_subnet.demo17-api-endpoint.id
  }

  options {
    service_lb_subnet_ids = [ oci_core_subnet.demo17-lbs.id ]

    add_ons {
      is_kubernetes_dashboard_enabled = var.oke_cluster_k8s_dashboard_enabled
      is_tiller_enabled               = var.oke_cluster_tiller_enabled
    }

    kubernetes_network_config {
      pods_cidr     = var.oke_k8s_network_config_pods_cidr
      services_cidr = var.oke_k8s_network_config_services_cidr
    }
  }
}

# --------- Create a node pool with worker nodes in the OKE cluster
resource oci_containerengine_node_pool demo17-npool {
  cluster_id          = oci_containerengine_cluster.demo17-oke.id
  compartment_id      = var.compartment_ocid
  kubernetes_version  = var.oke_node_pool_kubernetes_version
  name                = var.oke_node_pool_name
  node_shape          = var.oke_node_pool_node_shape
  ssh_public_key      = file(var.ssh_public_key_file)

  node_shape_config {
    memory_in_gbs = var.oke_node_pool_node_memory_in_gbs
    ocpus         = var.oke_node_pool_node_ocpus
  }

  node_source_details {
      source_type = "image"
      image_id    = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
  }

  node_config_details {
      size  = var.oke_node_pool_nb_worker_nodes
      
      # if we have 3 availability domains, place the nodes on the 3 ADs.
      dynamic "placement_configs" {
        for_each = data.oci_identity_availability_domains.ADs.availability_domains
        content {
          availability_domain = placement_configs.value.name
          subnet_id           = oci_core_subnet.demo17-workers.id
        }
      }
  }
}

data oci_containerengine_node_pool demo17-npool {
    node_pool_id = oci_containerengine_node_pool.demo17-npool.id
}

# # -------- Create a dynamic group containing the OCIDs of the compute instance in the node pool
# resource oci_identity_dynamic_group nodes_dg {
#     provider       = oci.home_region
#     compartment_id = var.tenancy_ocid
#     description    = "Demo 17 OKE (cpauliat)"
#     name           = "Demo17-cpauliat"
#     matching_rule  = "Any { ${join (", ", [for n in oci_containerengine_node_pool.demo17-npool.nodes : "instances.ocid = '${n.id}'" ])} }"
# }

# # -------- Add a tag to all compute instances in the node pool
# resource null_resource add_tag {
#   depends_on = [ oci_containerengine_node_pool.demo17-npool ]

#   provisioner "local-exec" {
#     command = join ("; ", [for n in oci_containerengine_node_pool.demo17-npool.nodes :
#         "echo OCI_object_add_tag -id ${n.id} -n tag_ns -k tag_key -vl tag_value" ])
#   }
# }

# # -------- List the OCIDs of compute instances in node pool
# output test {
#   value = [for n in oci_containerengine_node_pool.demo17-npool.nodes : n.id ]
# }

# --------- Create the Kubeconfig file
data oci_containerengine_cluster_kube_config demo17-oke {
    cluster_id = oci_containerengine_cluster.demo17-oke.id
}

resource local_file kubeconfig {
  content  = data.oci_containerengine_cluster_kube_config.demo17-oke.content
  filename = "kubeconfig"
  file_permission = "0700"
}

# --------- Create a service account and cluster role binding
# --------- Then get a authentication TOKEN to access Kubernetes Dashboard
resource local_file yaml {
  content = <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: oke-admin
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: oke-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: oke-admin
  namespace: kube-system
EOF
  filename = "oke-admin-service-account.yaml"
}

# --------- Create a script to create a service account get an authentication token to access dashboard
resource local_file get_token {
  content = <<EOF
export KUBECONFIG=./kubeconfig
echo "-- Create service account"
kubectl apply -f oke-admin-service-account.yaml
echo "-- Get an authentication token for this account"
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep oke-admin | awk '{print $1}') |grep "^token"|awk -F ' ' '{ print $2 }'
EOF
  filename = "create_oke-admin.sh"
}
