
  Wait a few minutes so that post-provisioning scripts can run on the compute instances
  Then you can use instructions below to connect

  ---- SSH connection to Oracle Linux 7 compute instances
  Run one of following commands on your Linux/MacOS desktop/laptop

  ssh -F sshcfg demo47-bastion             
%{ for inst in linux_instances ~}
  ssh -F sshcfg demo47-${lookup(inst,"hostname")}             
%{ endfor ~}

