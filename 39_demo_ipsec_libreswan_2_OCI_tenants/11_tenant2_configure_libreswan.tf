resource local_file ipsec_conf {
  content = templatefile("templates/ipsec.conf.tpl", {
    libreswan_private_ip  = oci_core_instance.demo39t2-libreswan.private_ip,
    libreswan_public_ip   = oci_core_instance.demo39t2-libreswan.public_ip,
    oci_ipsec_public_ip_1 = local.ipsec_ip1,
    oci_ipsec_public_ip_2 = local.ipsec_ip2,
  })
  filename = "ipsec.conf"
  file_permission = "0644"
}

resource local_file ipsec_secrets {
  content = templatefile("templates/ipsec.secrets.tpl", {
    secret_1              = local.ipsec_secret1,
    secret_2              = local.ipsec_secret2,
    oci_ipsec_public_ip_1 = local.ipsec_ip1,
    oci_ipsec_public_ip_2 = local.ipsec_ip2,
  })
  filename = "ipsec.secrets"
  file_permission = "0644"
}

resource null_resource configure_libreswan {
    depends_on = [ local_file.ipsec_conf, local_file.ipsec_secrets ]

    provisioner "file" {
        source        = "ipsec.conf"
        destination   = "/tmp/ipsec.conf"
        connection {
            host        = oci_core_instance.demo39t2-libreswan.public_ip
            user        = "opc"
            private_key = file(var.tenant2_ssh_private_key_file_ol7)
        }
    }

    provisioner "file" {
        source        = "ipsec.secrets"
        destination   = "/tmp/ipsec.secrets"
        connection {
            host        = oci_core_instance.demo39t2-libreswan.public_ip
            user        = "opc"
            private_key = file(var.tenant2_ssh_private_key_file_ol7)
        }
    }

    provisioner "remote-exec" {
        connection {
            host        = oci_core_instance.demo39t2-libreswan.public_ip
            user        = "opc"
            private_key = file(var.tenant2_ssh_private_key_file_ol7)
        }

        inline = [ 
            "sudo cloud-init status --wait",
            "sudo cp /tmp/ipsec.conf /tmp/ipsec.secrets /etc/ipsec.d",
            "sudo systemctl enable ipsec --now",
            "sleep 10",
            "sudo ip route replace ${var.tenant1_cidr_subnet_test} nexthop dev vti1 nexthop dev vti2" 
        ]
    }
}