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

    WAIT FOR WORKER NODES TO BE READY BEFORE USING THE CLUSTER ! (check status with 'kubectl get nodes')

    # ======== Kubernetes CLI
    You can now use Kubernetes CLI command kubectl (download the binary file for your OS) to manage your cluster
        $ export KUBECONFIG=./kubeconfig      (kubeconfig file just created)
        $ kubectl get nodes -o wide           (to see status of the worker nodes)

    # ======== Kubernetes WebUI
    To access Kubernetes Web Dashboard, 
      Run the following commands:
        $ . ./create_oke-admin.sh             (to create a service account oke-admin and get an authentication token)
        $ kubectl proxy -p 8002 &             (to start Kubernetes Web Dashboard on port 8002)
      Then open http://localhost:8002/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/ 
        in your Web browser and authenticate using the provided token
    
    # ======== Connections to nodes (optional)
    Optionally, you can SSH to the workers nodes thru bastion host with the following commands:
        $ ssh -F sshcfg oke-worker0
        $ ssh -F sshcfg oke-worker1
        ...

    If needed, you can SSH to the bastion host with following command:
        $ ssh -F sshcfg d17bastion

    # ======== Deploy an application (small Web server) in a Kubernetes pod using HELM
    If you have HELM installed on your machine, you can deploy Apache web server in K8s pod(s) using the following commands:
        $ kubectl create configmap required-files \
          --from-file=welcome_page/index.html \
          --from-file=welcome_page/background.jpg \
          --from-file=welcome_page/oracle_tag.png \
          --from-file=welcome_page/osc_logo_white.png 
        $ helm repo add bitnami https://charts.bitnami.com/bitnami
        $ helm repo update
        $ helm install apache bitnami/apache --set service.type=LoadBalancer --set htdocsConfigMap=required-files
     OR $ helm install apache bitnami/apache --set service.type=LoadBalancer --set htdocsConfigMap=required-files --set replicaCount=2  (if you want 2 pods)
        $ helm list

    THIS WILL DEPLOY IN THE BACKGROUND AN OCI LOAD BALANCER WITH PUBLIC IP ADDRESS TO ACCESS NGINX

    # ======== Look at Kubernetes objects created 
    You can then list pods, deployments and services using the following commands: 
        $ kubectl get pods -o wide
        $ kubectl describe pods <pod_name>
        $ kubectl get deployment -o wide 
        $ kubectl get replicaset -o wide 
        $ kubectl get services -o wide      

    WAIT FOR THE LOAD BALANCER TO BE CREATED (look for public IP in EXTERNAL-IP column in previous command)

    # ======== Access the web server thru the OCI load balancer
    In your web browser, open http://<public-ip-load-balancer> or https://<public-ip-load-balancer>

    # ======== Get a shell inside a Kubernetes pod (optional)
    You connect to a pod using the following command:
        $ kubectl exec -it <pod_name> -- /bin/bash

    # ======== Uninstall the application
    After you test, you can delete the K8s pod, deployment and service (including OCI load balancer) using the following command:
        $ helm uninstall apache

EOF

}

        # $ helm repo add nginx-stable https://helm.nginx.com/stable
        # $ helm install nginx-ingress nginx-stable/nginx-ingress
