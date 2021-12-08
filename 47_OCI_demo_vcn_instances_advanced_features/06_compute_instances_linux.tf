# ------ Create the Oracle Linux 7 compute instances in private subnets
locals {
  private_subnets_list = [ for subnet in var.private_subnets: lookup(subnet,"name") ]
}

resource oci_core_instance demo47-instances-linux {
  # ignore change in cloudinit file after provisioning
  lifecycle {
    ignore_changes = [
      metadata
    ]
  }
  count                = length(var.linux_instances)
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = lookup(var.linux_instances[count.index], "hostname")
  preserve_boot_volume = "false"
  fault_domain         = "FAULT-DOMAIN-${lookup(var.linux_instances[count.index], "fd")}"
  shape                = lookup(var.linux_instances[count.index], "shape")

  dynamic "shape_config" {
    for_each = (lookup(var.linux_instances[count.index], "shape") == "VM.Standard.E3.Flex") ? [ 1 ] : [ ]
    content {
        ocpus         = lookup(var.linux_instances[count.index], "ocpus")
        memory_in_gbs = lookup(var.linux_instances[count.index], "memory")
    }
  }  

  create_vnic_details {
    subnet_id        = lookup(oci_core_subnet.demo47-private-subnet[index(local.private_subnets_list, lookup(var.linux_instances[count.index], "subnet"))], "id")
    hostname_label   = lookup(var.linux_instances[count.index], "hostname")
    private_ip       = lookup(var.linux_instances[count.index], "private_ip")
    assign_public_ip = false
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
    #source_id    = var.ol7_image_ocid
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file)
    user_data           = base64encode(file(var.linux_cloud_init_file))
  }
}

# ------ Create one block volume for each compute instance
resource oci_core_volume demo47-instances-linux {
  count               = length(var.linux_instances)
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = "demo47-vol1-${lookup(var.linux_instances[count.index], "hostname")}"
  size_in_gbs         = lookup(var.linux_instances[count.index], "blk_vol")
}

# ------ Attach the block volumes to the linux compute instances
resource oci_core_volume_attachment demo47-instances-linux {
  count           = length(var.linux_instances)
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.demo47-instances-linux[count.index].id
  volume_id       = oci_core_volume.demo47-instances-linux[count.index].id
  device          = "/dev/oracleoci/oraclevdb"

  provisioner "remote-exec" {
    connection {
      bastion_host        = oci_core_instance.demo47-bastion.public_ip
      bastion_user        = "opc"
      bastion_private_key = file(var.bastion_ssh_private_key_file)
      host                = oci_core_instance.demo47-instances-linux[count.index].private_ip
      user                = "opc"
      private_key         = file(var.ssh_private_key_file)
    }

    inline = [
      "sudo -s bash -c 'set -x && iscsiadm -m node -o new -T ${self.iqn} -p ${self.ipv4}:${self.port}'",
      "sudo -s bash -c 'set -x && iscsiadm -m node -o update -T ${self.iqn} -n node.startup -v automatic '",
      "sudo -s bash -c 'set -x && iscsiadm -m node -T ${self.iqn} -p ${self.ipv4}:${self.port} -l '",
    ]
  }
}
