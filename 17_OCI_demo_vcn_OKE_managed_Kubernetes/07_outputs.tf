# --------- Create a SSH config file to connect to worker nodes
resource null_resource nodes_ready {
  depends_on = [ oci_containerengine_node_pool.demo17-npool ]
  provisioner "local-exec" {
    command = "echo 'Wait 5 minutes for the worker nodes to be ready'; sleep 300"
  }
}

resource local_file sshconfig {
  depends_on = [ null_resource.nodes_ready ]
  content = templatefile("templates/sshcfg.tpl", {
    bastion_public_ip               = oci_core_instance.demo17-bastion.public_ip,
    bastion_ssh_private_key_file    = var.ssh_private_key_file_bastion,
    nodes                           = data.oci_containerengine_node_pool.demo17-npool.nodes,
    nodes_ssh_private_key_file      = var.ssh_private_key_file
  })
  filename = "sshcfg"
  file_permission = "0644"
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
    
    Optionally, you can SSH to the workers nodes thru bastion host with the following commands:
        $ ssh -F sshcfg oke-worker0
        $ ssh -F sshcfg oke-worker1
        ...

    If needed, you can SSH to the bastion host with following command:
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

