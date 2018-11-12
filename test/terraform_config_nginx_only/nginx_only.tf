variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "compartment_ocid" {}
variable "vcn_ocid" {}
variable "bastion_subnet" {}
variable "bastion_shape" {}
variable "bastion_ssh_authorized_keys" {}
variable "bastion_ssh_private_key" {}
variable "bastion_host_display_name" {}
variable "bastion_image_id" {}
variable "server_count" {}

variable "server_subnet_ids" {
  type = "list"
}

variable "server_display_name" {}
variable "server_shape" {}
variable "server_image_id" {}
variable "server_http_port" {}
variable "server_ssh_authorized_keys" {}
variable "server_ssh_private_key" {}

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
  bastion_host_display_name   = "${var.bastion_host_display_name}"
  server_count                = "${var.server_count}"
  server_subnet_ids           = "${var.server_subnet_ids}"
  server_display_name         = "${var.server_display_name}"
  server_shape                = "${var.server_shape}"
  server_image_id             = "${var.server_image_id}"
  server_http_port            = "${var.server_http_port}"
  server_ssh_authorized_keys  = "${var.server_ssh_authorized_keys}"
  server_ssh_private_key      = "${var.server_ssh_private_key}"
}

output "nginx_server_private_ips" {
  value = "${module.nginx.private_ips}"
}

output "server_http_port" {
  value = "${module.nginx.server_http_port}"
}
