resource oci_database_database_software_image si {
    compartment_id     = var.vmcluster_compartment_id
    display_name       = "CPA_IMAGE_19.10"
    database_version   = "19.0.0.0"
    patch_set          = "19.10.0.0"
    image_shape_family = "EXACC_SHAPE"      # not VM_BM_SHAPE

    # database_software_image_one_off_patches = var.database_software_image_database_software_image_one_off_patches
    # image_type = var.database_software_image_image_type
    # ls_inventory = var.database_software_image_ls_inventory
}

# oci_database_database_software_image.si: Creation complete after 16m35s 
# oci_database_database_software_image.si: Destruction complete after 15s
# oci_database_database_software_image.si: Destruction complete after 16s