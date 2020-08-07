# --------- Create an OKE cluster
resource "oci_containerengine_cluster" "tf-demo17-oke" {
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.oke_cluster_k8s_version
  name               = var.oke_cluster_name
  vcn_id             = oci_core_virtual_network.tf-demo17-vcn.id

  options {
    service_lb_subnet_ids = [oci_core_subnet.tf-demo17-lb.id]

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
resource "oci_containerengine_node_pool" "tf-demo17-npool" {
  cluster_id         = oci_containerengine_cluster.tf-demo17-oke.id
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.oke_node_pool_kubernetes_version
  name               = var.oke_node_pool_name
  node_shape         = var.oke_node_pool_node_shape

  node_source_details {
      source_type = "image"
      image_id    = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
  }

  node_config_details {
      size  = var.oke_node_pool_nb_worker_nodes
      placement_configs {
        availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0]["name"]
        subnet_id           = oci_core_subnet.tf-demo17-worker.id
      }
      placement_configs {
        availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[1]["name"]
        subnet_id           = oci_core_subnet.tf-demo17-worker.id
      }
      placement_configs {
        availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[2]["name"]
        subnet_id           = oci_core_subnet.tf-demo17-worker.id
      }
  }

  ssh_public_key      = file(var.ssh_public_key_file)
}

data "oci_containerengine_node_pool" "tf-demo17-npool" {
    node_pool_id = oci_containerengine_node_pool.tf-demo17-npool.id
}

# --------- Create a SSH config file to connect to worker nodes
resource "null_resource" "nodes_ready" {
  depends_on = [ oci_containerengine_node_pool.tf-demo17-npool ]
  provisioner "local-exec" {
    command = "echo 'Wait 6 minutes for the worker nodes to be ready'; sleep 360"
  }
}

resource "local_file" "sshconfig" {
  depends_on = [ null_resource.nodes_ready ]
  content = <<EOF
Host oke-worker${substr(strrev(oci_containerengine_node_pool.tf-demo17-npool.nodes[0].name), 0, 1)}
          Hostname ${data.oci_containerengine_node_pool.tf-demo17-npool.nodes[0].public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file}
Host oke-worker${substr(strrev(oci_containerengine_node_pool.tf-demo17-npool.nodes[1].name), 0, 1)}
          Hostname ${data.oci_containerengine_node_pool.tf-demo17-npool.nodes[1].public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file}
Host oke-worker${substr(strrev(oci_containerengine_node_pool.tf-demo17-npool.nodes[2].name), 0, 1)}
          Hostname ${data.oci_containerengine_node_pool.tf-demo17-npool.nodes[2].public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file}
EOF
  filename = "sshcfg"
}

#Host oke-worker${substr(strrev(oci_containerengine_node_pool.tf-demo17-npool.nodes[2].name), 0, 1)}


# --------- Create the Kubeconfig file
data "oci_containerengine_cluster_kube_config" "tf-demo17-oke" {
    cluster_id = oci_containerengine_cluster.tf-demo17-oke.id
}

resource "local_file" "kubeconfig" {
  content  = data.oci_containerengine_cluster_kube_config.tf-demo17-oke.content
  filename = "kubeconfig"
}

# --------- Create a service account and cluster role binding
# --------- Then get a authentication TOKEN to access Kubernetes Dashboard
resource "local_file" "yaml" {
  content = <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: oke-admin
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
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
resource "local_file" "get_token" {
  content = <<EOF
export KUBECONFIG=./kubeconfig
echo "-- Create service account"
kubectl apply -f oke-admin-service-account.yaml
echo "-- Get an authentication token for this account"
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep oke-admin | awk '{print $1}') |grep "^token"|awk -F ' ' '{ print $2 }'
EOF
  filename = "create_oke-admin.sh"
}

output "INSTRUCTIONS" {
  value = <<EOF

    File kubeconfig was created
    The worker nodes are being provisioned in the background.

    You can now use Kubernetes CLI command kubectl (download the binary file for your OS) to manage your cluster
        $ export KUBECONFIG=./kubeconfig      (kubeconfig file just created)
        $ kubectl get nodes                   (to see status of the worker nodes)

    To access Kubernetes Web Dashboard, 
      Run the following commands:
        $ . ./create_oke-admin.sh             (to create a service account oke-admin and get an authentication token)
        $ kubectl proxy -p 8002 &             (to start Kubernetes Web Dashboard on port 8002)
      Then open http://localhost:8002/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/ 
        in your Web browser and authenticate using the provided token

    Wait for worker nodes to be ready before using the cluster
    
    Optionally, you can SSH to the workers nodes with following commands:
        $ ssh -F sshcfg oke-worker0
        $ ssh -F sshcfg oke-worker1
        $ ssh -F sshcfg oke-worker2

EOF

}

