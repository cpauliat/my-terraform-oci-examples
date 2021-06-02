# --------- Get the OCID for the most recent for Oracle Linux 7.x disk image
data oci_core_images ImageOCID-ol7 {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "7.9"

  # filter to avoid Oracle Linux 7.x images for GPU and ARM
  filter {
    name   = "display_name"
    values = ["^.*Oracle-Linux-7.9-202.*$"]
    regex  = true
  }
}

# ------ Generate a random password for VNC user opc
resource random_string vnc_password_opc {
  # must contains at least 2 upper case letters, 2 lower case letters, 2 numbers and 2 special characters
  length      = 12
  upper       = true
  min_upper   = 2
  lower       = true
  min_lower   = 2
  number      = true
  min_numeric = 2
  special     = true
  min_special = 2
  override_special = "#_-"   # use only special characters in this list
}

# ------ Create a network security group to allow SSH connections from specific public IPs 
resource oci_core_network_security_group demo35 {
    compartment_id = var.compartment_ocid
    vcn_id         = oci_core_vcn.demo35-vcn.id
    display_name   = "demo35"
}

resource oci_core_network_security_group_security_rule demo35-secrule1 {
    network_security_group_id = oci_core_network_security_group.demo35.id
    direction                 = "INGRESS"
    protocol                  = "6"       # for ICMP ("1"), TCP ("6"), UDP ("17"), and ICMPv6 ("58")
    description               = "Allow SSH connection from C. Pauliat's public IP"
    source                    = var.authorized_ips
    source_type               = "CIDR_BLOCK"
    tcp_options {
        destination_port_range {
            max = "22"
            min = "22"
        }
    }
}

resource oci_core_network_security_group_security_rule demo35-secrule2 {
    network_security_group_id = oci_core_network_security_group.demo35.id
    direction                 = "INGRESS"
    protocol                  = "6"       # for ICMP ("1"), TCP ("6"), UDP ("17"), and ICMPv6 ("58")
    description               = "Allow Remote Desktop connection to noVNC on port HTTPS 443"
    source                    = var.authorized_ips
    source_type               = "CIDR_BLOCK"
    tcp_options {
        destination_port_range {
            max = "443"
            min = "443"
        }
    }
}

# ------ Create a REMOTE DESKTOP ion compute instance (OL7.x) 
resource oci_core_instance demo35 {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "demo35: remote desktop noVNC"
  shape                = "VM.Standard.E2.1"
  preserve_boot_volume = "false"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.demo35-subnet1.id
    hostname_label   = "demo35"
    assign_public_ip = "true"
    nsg_ids          = [oci_core_network_security_group.demo35.id]
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file_rdesktop)
    user_data           = base64encode(file(var.BootStrapFile_rdesktop))
    myarg_vnc_password  = random_string.vnc_password_opc.result
  }
}

# ------ Display the complete ssh command needed to connect to the instance
output demo35 {
  value = <<EOF

  ---- You can SSH directly to the demo35 compute instance by typing the following ssh command
  ssh -i ${var.ssh_private_key_file_rdesktop} opc@${oci_core_instance.demo35.public_ip}

  ---- Connection to noVNC HTTP WebUI
  Open https://${oci_core_instance.demo35.public_ip} in your web browser  (Self signed certificate)
    then use
    opc password = ${random_string.vnc_password_opc.result}

  OR (LESS SECURE)
    just open https://${oci_core_instance.demo35.public_ip}/vnc.html?password=${random_string.vnc_password_opc.result}
    then click Connect
  EOF
}
