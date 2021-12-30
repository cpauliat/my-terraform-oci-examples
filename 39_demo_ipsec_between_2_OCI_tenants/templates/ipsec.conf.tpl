conn oci-tunnel-1
     left=${libreswan_private_ip}
     #leftid=${libreswan_public_ip}
     right=${oci_ipsec_public_ip_1}
     authby=secret
     leftsubnet=0.0.0.0/0
     rightsubnet=0.0.0.0/0
     auto=start
     mark=5/0xffffffff # Needs to be unique across all tunnels
     vti-interface=vti1
     vti-routing=no
     ikev2=no   #insist # no: To use IKEv2, change to ikev2=insist
     ike=aes_cbc256-sha2_384;modp1536
     phase2alg=aes_gcm256;modp1536
     encapsulation=yes
     ikelifetime=28800s
     salifetime=3600s

conn oci-tunnel-2
     left=${libreswan_private_ip}
     #leftid=${libreswan_public_ip}
     right=${oci_ipsec_public_ip_2}
     authby=secret
     leftsubnet=0.0.0.0/0
     rightsubnet=0.0.0.0/0
     auto=start
     mark=6/0xffffffff # Needs to be unique across all tunnels
     vti-interface=vti2
     vti-routing=no
     ikev2=no   #insist # no: To use IKEv2, change to ikev2=insist
     ike=aes_cbc256-sha2_384;modp1536
     phase2alg=aes_gcm256;modp1536
     encapsulation=yes
     ikelifetime=28800s
     salifetime=3600s