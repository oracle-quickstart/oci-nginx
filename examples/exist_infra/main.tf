// Copyright (c) 2018, Oracle and/or its affiliates. All rights reserved.

provider "oci" {
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region           = "${var.region}"
}

module "nginx" {
  source                      = "../../"
  compartment_ocid            = "${var.compartment_ocid}"
  vcn_ocid                    = "${var.vcn_ocid}"
  bastion_subnet              = "${var.bastion_subnet}"
  bastion_shape               = "${var.bastion_shape}"
  bastion_ssh_authorized_keys = "${var.bastion_ssh_authorized_keys}"
  bastion_ssh_private_key     = "${var.bastion_ssh_private_key}"
  server_count                = "${var.server_count}"
  server_subnet_ids           = "${var.server_subnet_ids}"
  server_display_name         = "${var.server_display_name_prefix}"
  server_shape                = "${var.server_shape}"
  server_image_id             = "${var.image_id}"
  server_http_port            = "${var.http_port}"
  server_ssh_authorized_keys  = "${var.server_ssh_authorized_keys}"
  server_ssh_private_key      = "${var.server_ssh_private_key}"
}
