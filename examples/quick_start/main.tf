// Copyright (c) 2018, Oracle and/or its affiliates. All rights reserved.

provider "oci" {
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region           = "${var.region}"
}

data "oci_identity_availability_domains" "ad" {
  compartment_id = "${var.compartment_id}"
}

# Define local variables
locals {
  tcp_protocol                     = "6"
  all_protocol                     = "all"
  anywhere                         = "0.0.0.0/0"
  dmz_tier_prefix                  = "${cidrsubnet(var.vcn_cidr, 4, 0)}"
  app_tier_prefix                  = "${cidrsubnet(var.vcn_cidr, 4, 1)}"
  nginx_subnet_prefix              = "${cidrsubnet("${local.dmz_tier_prefix}", 4, 2)}"
  bs_subnet_prefix                 = "${cidrsubnet("${local.app_tier_prefix}", 4, 1)}"
  lb_subnet_prefix                 = "${cidrsubnet("${local.app_tier_prefix}", 4, 0)}"
  bs_availability_domain           = "${lookup(data.oci_identity_availability_domains.ad.availability_domains[0], "name")}"
  lb_subnet_count                  = "${min(length(data.oci_identity_availability_domains.ad.availability_domains),var.server_count)}"
  NATGW_id_temp_file_name          = ".oci_core_route_table.with_NATGW.id"
  bastion_subnet_id_temp_file_name = ".oci_core_subnet.bastion.id"
}

# Create a Virtual Cloud Network resource 
resource "oci_core_vcn" "nginx" {
  compartment_id = "${var.compartment_id}"
  display_name   = "vcn_nginx"
  cidr_block     = "${var.vcn_cidr}"
  dns_label      = "tfnginx"
}

# Create a Internet Gateway resource 
resource "oci_core_internet_gateway" "IGW_nginx" {
  compartment_id = "${var.compartment_id}"
  vcn_id         = "${oci_core_vcn.nginx.id}"
  display_name   = "IGW_nginx"
}

# Create a Route Table resource for the Virtual Cloud Network and configured with the created Internet Gateway 
resource "oci_core_route_table" "routeTable_nginx_IGW" {
  compartment_id = "${var.compartment_id}"
  vcn_id         = "${oci_core_vcn.nginx.id}"
  display_name   = "routeTable_nginx"

  route_rules {
    destination       = "${local.anywhere}"
    network_entity_id = "${oci_core_internet_gateway.IGW_nginx.id}"
  }
}

# Create a NAT gateway when using the bastion to do the setup 
resource "oci_core_nat_gateway" "NATGW_nginx" {
  compartment_id = "${var.compartment_id}"
  vcn_id         = "${oci_core_vcn.nginx.id}"
  display_name   = "NAT_GW_nginx"
}

# Create a Route Table resource for the Virtual Cloud Network and configured with the created NAT Gateway 
resource "oci_core_route_table" "nginx_natgw" {
  compartment_id = "${var.compartment_id}"
  vcn_id         = "${oci_core_vcn.nginx.id}"
  display_name   = "routeTable_nginx_with_NATGW"

  route_rules {
    destination       = "${local.anywhere}"
    network_entity_id = "${oci_core_nat_gateway.NATGW_nginx.id}"
  }
}

# Create a security list for ssh port
resource "oci_core_security_list" "nginx_ssh" {
  compartment_id = "${var.compartment_id}"
  display_name   = "seclist_nginx_ssh"
  vcn_id         = "${oci_core_vcn.nginx.id}"

  egress_security_rules = [{
    protocol    = "${local.all_protocol}"
    destination = "${local.anywhere}"
  }]

  ingress_security_rules = [
    {
      protocol = "${local.tcp_protocol}"
      source   = "${local.anywhere}"

      tcp_options {
        "min" = 22
        "max" = 22
      }
    },
  ]
}

# Create a security list for http port
resource "oci_core_security_list" "nginx_http" {
  compartment_id = "${var.compartment_id}"
  display_name   = "seclist_nginx_http"
  vcn_id         = "${oci_core_vcn.nginx.id}"

  egress_security_rules = [{
    protocol    = "${local.all_protocol}"
    destination = "${local.anywhere}"
  }]

  ingress_security_rules = [{
    protocol = "${local.tcp_protocol}"
    source   = "${local.anywhere}"

    tcp_options {
      "min" = "${var.http_port}"
      "max" = "${var.http_port}"
    }
  }]
}

# Create Subnet resource 
resource "oci_core_subnet" "nginx" {
  # every AD has a lb subnet, also need check the number of the nginx server counts
  count               = "${min(length(data.oci_identity_availability_domains.ad.availability_domains),var.server_count)}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ad.availability_domains[count.index], "name")}"
  compartment_id      = "${var.compartment_id}"
  display_name        = "nginx_subnet_ad${count.index}"
  cidr_block          = "${cidrsubnet(local.nginx_subnet_prefix, 4, count.index)}"
  security_list_ids   = ["${oci_core_security_list.nginx_http.id}", "${oci_core_security_list.nginx_ssh.id}"]
  vcn_id              = "${oci_core_vcn.nginx.id}"
  route_table_id      = "${oci_core_route_table.nginx_natgw.id}"
}

# Create the subnet for bastion host
resource "oci_core_subnet" "bastion" {
  availability_domain = "${local.bs_availability_domain}"
  compartment_id      = "${var.compartment_id}"
  display_name        = "bastion_subnet"
  cidr_block          = "${local.bs_subnet_prefix}"
  security_list_ids   = ["${oci_core_security_list.nginx_ssh.id}"]
  vcn_id              = "${oci_core_vcn.nginx.id}"
  route_table_id      = "${oci_core_route_table.routeTable_nginx_IGW.id}"
}

# Create the subnets for load balance
resource "oci_core_subnet" "load_balance" {
  count               = 2
  availability_domain = "${lookup(data.oci_identity_availability_domains.ad.availability_domains[count.index], "name")}"
  compartment_id      = "${var.compartment_id}"
  display_name        = "load_balance_subnet-${count.index}"
  cidr_block          = "${cidrsubnet(local.lb_subnet_prefix, 4, count.index)}"
  security_list_ids   = ["${oci_core_security_list.nginx_http.id}"]
  vcn_id              = "${oci_core_vcn.nginx.id}"
  route_table_id      = "${oci_core_route_table.routeTable_nginx_IGW.id}"
}

# Create the bastion host
module "bastion_host" {
  source                = "./modules/compute-instance"
  compartment_id        = "${var.compartment_id}"
  instance_display_name = "${var.bastion_host_display_name}"
  source_ocid           = "${coalesce(var.bastion_image_id, var.image_id[var.region])}"
  vcn_ocid              = "${oci_core_vcn.nginx.id}"
  subnet_ocid           = "${list(element(oci_core_subnet.bastion.*.id, 0))}"
  ssh_authorized_keys   = "${coalesce(var.bastion_ssh_authorized_keys, var.server_ssh_authorized_keys)}"
  shape                 = "${coalesce(var.bastion_shape, var.server_shape)}"
  assign_public_ip      = true
  instance_count        = 1
}

module "nginx" {
  source                      = "../../"
  compartment_id              = "${var.compartment_id}"
  vcn_ocid                    = "${oci_core_vcn.nginx.id}"
  bastion_host_public_ip      = "${element(module.bastion_host.public_ip, 0)}"
  bastion_host_user           = "${var.bastion_host_user}"
  bastion_ssh_authorized_keys = "${coalesce(var.bastion_ssh_authorized_keys, var.server_ssh_authorized_keys)}"
  bastion_ssh_private_key     = "${coalesce(var.bastion_ssh_private_key, var.server_ssh_private_key)}"
  server_count                = "${var.server_count}"
  server_subnet_ids           = ["${oci_core_subnet.nginx.*.id}"]
  server_display_name         = "${var.server_display_name}"
  server_shape                = "${var.server_shape}"
  server_image_id             = "${var.image_id[var.region]}"
  server_http_port            = "${var.http_port}"
  server_https_port           = "${var.server_https_port}"
  server_ssh_authorized_keys  = "${var.server_ssh_authorized_keys}"
  server_ssh_private_key      = "${var.server_ssh_private_key}"
  ssl_cert_file_path          = "${var.ssl_cert_file_path}"
  ssl_cert_key_file_path      = "${var.ssl_cert_key_file_path}"
}

module "load_balancer" {
  source                          = "./modules/load-balancer"
  compartment_id                  = "${var.compartment_id}"
  display_name                    = "nginx_lb"
  shape                           = "${var.shape}"
  is_private                      = false
  subnet_ids                      = ["${oci_core_subnet.load_balance.*.id}"]
  backendset_name                 = "${var.backendset_name}"
  backendset_policy               = "${var.backendset_policy}"
  hc_protocol                     = "${var.hc_protocol}"
  hc_port                         = "${var.http_port}"
  hc_interval_ms                  = "${var.hc_interval_ms}"
  hc_retries                      = "${var.hc_retries}"
  hc_return_code                  = "${var.hc_return_code}"
  hc_timeout_in_millis            = "${var.hc_timeout_in_millis}"
  hc_response_body_regex          = "${var.hc_response_body_regex}"
  hc_url_path                     = "${var.hc_url_path}"
  backend_count                   = "${var.server_count}"
  backend_ips                     = "${module.nginx.private_ips}"
  backend_ports                   = ["${var.http_port}"]
  backup                          = "${var.backup}"
  drain                           = "${var.drain}"
  offline                         = "${var.offline}"
  weight                          = "${var.weight}"
  path_route_set_name             = "${var.path_route_set_name}"
  path                            = "${var.path}"
  path_match_type                 = "${var.path_match_type}"
  hostnames                       = "${var.hostnames}"
  hostname_names                  = "${var.hostname_names}"
  listener_certificate_name       = "${var.listener_certificate_name}"
  listener_ca_certificate         = "${var.listener_ca_certificate}"
  listener_passphrase             = "${var.listener_passphrase}"
  listener_private_key            = "${var.listener_private_key}"
  listener_public_certificate     = "${var.listener_public_certificate}"
  listener_protocol               = "${var.hc_protocol}"
  ssl_listener_name               = "${var.ssl_listener_name}"
  ssl_listener_port               = "${var.ssl_listener_port}"
  ssl_verify_peer_certificate     = "${var.ssl_verify_peer_certificate}"
  ssl_verify_depth                = "${var.ssl_verify_depth}"
  ssl_listener_hostnames          = "${var.ssl_listener_hostnames}"
  ssl_listener_path_route_set     = "${var.ssl_listener_path_route_set}"
  non_ssl_listener_name           = "${var.non_ssl_listener_name}"
  non_ssl_listener_port           = "${var.http_port}"
  non_ssl_listener_hostnames      = "${var.non_ssl_listener_hostnames}"
  non_ssl_listener_path_route_set = "${var.non_ssl_listener_path_route_set}"
}
