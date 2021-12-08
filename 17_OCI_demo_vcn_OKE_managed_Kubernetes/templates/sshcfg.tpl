Host d17bastion
          Hostname ${bastion_public_ip}
          User opc
          IdentityFile ${bastion_ssh_private_key_file}
          StrictHostKeyChecking no
%{ for node in nodes ~}
Host oke-worker${substr(strrev(lookup(node,"name")), 0, 1)}
          Hostname ${lookup(node,"private_ip")}
          User opc
          IdentityFile ${nodes_ssh_private_key_file}
          StrictHostKeyChecking no
          ProxyJump d17bastion
%{ endfor ~}