Host demo47-bastion
          Hostname ${bastion_public_ip}
          User opc
          IdentityFile ${bastion_ssh_private_key_file}
          StrictHostKeyChecking no
%{ for inst in linux_instances ~}
Host demo47-${lookup(inst,"hostname")}
          Hostname ${lookup(inst,"private_ip")}
          User opc
          IdentityFile ${linux_ssh_private_key_file}
          StrictHostKeyChecking no
          proxycommand /usr/bin/ssh -F sshcfg -W %h:%p demo47-bastion
%{ endfor ~}
