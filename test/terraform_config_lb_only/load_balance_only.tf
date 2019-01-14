variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "compartment_id" {}
variable "vcn_ocid" {}
variable "server_count" {}
variable "server_http_port" {}

variable "lb_shape" {
  default = "100Mbps"
}

variable "lb_subnet_ids" {
  default = []
}
variable "backendset_name" {
  default = "AutoTestbackendset"
}
variable "backendset_policy" {
  default = "LEAST_CONNECTIONS"
}
variable "hc_protocol" {
  default = "HTTP"
}

variable "hc_interval_ms" {
  default = 30000
}

variable "hc_retries" {
  default = 3
}

variable "hc_return_code" {
  default = 200
}

variable "hc_timeout_in_millis" {
  default = 3000
}

variable "hc_response_body_regex" {
  default = ""
}

variable "hc_url_path" {
  default = "/"
}

variable "backend_ips" {
  default = []
}

variable "backup" {
  default = []
}

variable "drain" {
  default = []
}

variable "offline" {
  default = []
}

variable "weight" {
  default = []
}

variable "path_route_set_name" {
  default = ""
}

variable "path" {
  default = ""
}

variable "path_match_type" {
  default = ""
}

variable "hostnames" {
  default = ["www.autotest1.com", "www.autotest2.com"]
}

variable "hostname_names" {
  default = ["AUTOTEST1", "AUTOTEST2"]
}

variable "listener_certificate_name" {
  default = ""
}

variable "listener_ca_certificate" {
  default = ""
}

variable "listener_passphrase" {
  default = ""
}

variable "listener_private_key" {
  default = ""
}

variable "listener_public_certificate" {
  default = ""
}

variable "ssl_listener_name" {
  default = ""
}

variable "ssl_listener_port" {
  default = ""
}
variable "ssl_verify_peer_certificate" {
  default = true
}
variable "ssl_verify_depth" {
  default = 5
}
variable "ssl_listener_hostnames" {
  default = []
}
variable "ssl_listener_path_route_set" {
  default = ""
}
variable "non_ssl_listener_name" {
  default = "AutoTestNonSSLListener"
}
variable "non_ssl_listener_hostnames" {
  default = []
}
variable "non_ssl_listener_path_route_set" {
  default = ""
}

module "load_balancer" {
  source                          = "./modules/load-balancer"
  compartment_id                  = "${var.compartment_id}"
  display_name                    = "nginx_lb"
  shape                           = "${var.lb_shape}"
  is_private                      = false
  subnet_ids                      = "${var.lb_subnet_ids}"
  backendset_name                 = "${var.backendset_name}"
  backendset_policy               = "${var.backendset_policy}"
  hc_protocol                     = "${var.hc_protocol}"
  hc_port                         = "${var.server_http_port}"
  hc_interval_ms                  = "${var.hc_interval_ms}"
  hc_retries                      = "${var.hc_retries}"
  hc_return_code                  = "${var.hc_return_code}"
  hc_timeout_in_millis            = "${var.hc_timeout_in_millis}"
  hc_response_body_regex          = "${var.hc_response_body_regex}"
  hc_url_path                     = "${var.hc_url_path}"
  backend_count                   = "${var.server_count}"
  backend_ips                     = "${var.backend_ips}"
  backend_ports                   = ["${var.server_http_port}"]
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
  non_ssl_listener_port           = "${var.server_http_port}"
  non_ssl_listener_hostnames      = "${var.non_ssl_listener_hostnames}"
  non_ssl_listener_path_route_set = "${var.non_ssl_listener_path_route_set}"
}

output "lb_endpoint" {
  value = "${module.load_balancer.ip_addresses}"
}