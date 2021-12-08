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

# --------- Create a SSH config file to connect to worker nodes
resource null_resource nodes_ready {
  depends_on = [ oci_containerengine_node_pool.demo17-npool ]
  provisioner "local-exec" {
    command = "echo 'Wait 5 minutes for the worker nodes to be ready'; sleep 300"
  }
}

resource local_file sshconfig {
  depends_on = [ null_resource.nodes_ready ]
  content = <<EOF
Host d17bastion
          Hostname ${oci_core_instance.demo17-bastion.public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_bastion}
Host oke-worker${substr(strrev(data.oci_containerengine_node_pool.demo17-npool.nodes[0].name), 0, 1)}
          Hostname ${data.oci_containerengine_node_pool.demo17-npool.nodes[0].private_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file}
          ProxyJump d17bastion
Host oke-worker${substr(strrev(data.oci_containerengine_node_pool.demo17-npool.nodes[1].name), 0, 1)}
          Hostname ${data.oci_containerengine_node_pool.demo17-npool.nodes[1].private_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file}
          ProxyJump d17bastion
Host oke-worker${substr(strrev(data.oci_containerengine_node_pool.demo17-npool.nodes[2].name), 0, 1)}
          Hostname ${data.oci_containerengine_node_pool.demo17-npool.nodes[2].private_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file}
          ProxyJump d17bastion
EOF
  filename = "sshcfg"
}

# --------- Create the Kubeconfig file
data oci_containerengine_cluster_kube_config demo17-oke {
    cluster_id = oci_containerengine_cluster.demo17-oke.id
}

resource local_file kubeconfig {
  content  = data.oci_containerengine_cluster_kube_config.demo17-oke.content
  filename = "kubeconfig"
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

output INSTRUCTIONS {
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
    
    Optionally, you can SSH to the workers nodes thru bastion host with following commands:
        $ ssh -F sshcfg oke-worker0
        $ ssh -F sshcfg oke-worker1
        $ ssh -F sshcfg oke-worker2
        $ ssh -F sshcfg d17bastion

    If you have HELM installed on your machine, you can deploy NGNIX in a K8s pod using the following commands:
        $ helm repo add nginx-stable https://helm.nginx.com/stable
        $ helm repo update
        $ helm install nginx-ingress nginx-stable/nginx-ingress
        $ helm list

    You can then list pods and display details for pod using the following commands: 
        $ kubectl get pods -o wide
        $ kubectl describe pods <pod_name>    

    THIS WILL DEPLOY AN OCI LOAD BALANCER WITH PUBLIC IP ADDRESS TO ACCESS NGINX

    After you test, you can delete the K8s pod using the following command:
        $ helm uninstall nginx-ingress

EOF

}

