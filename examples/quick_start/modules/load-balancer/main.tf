// Copyright (c) 2018, Oracle and/or its affiliates. All rights reserved.

resource "oci_load_balancer" "this" {
  compartment_id = "${var.compartment_id}"
  display_name   = "${var.display_name}"
  shape          = "${var.shape}"
  subnet_ids     = ["${var.subnet_ids}"]

  // Optional
  is_private = "${var.is_private}"
}

resource "oci_load_balancer_backendset" "this" {
  load_balancer_id = "${oci_load_balancer.this.id}"
  name             = "${var.backendset_name}"
  policy           = "${var.backendset_policy}"

  health_checker {
    protocol            = "${var.hc_protocol}"
    port                = "${var.hc_port}"
    interval_ms         = "${var.hc_interval_ms}"
    retries             = "${var.hc_retries}"
    return_code         = "${var.hc_return_code}"
    timeout_in_millis   = "${var.hc_timeout_in_millis}"
    response_body_regex = "${var.hc_response_body_regex}"
    url_path            = "${var.hc_url_path}"
  }
}

resource "oci_load_balancer_backend" "this" {
  count            = "${var.backend_count}"
  load_balancer_id = "${oci_load_balancer.this.id}"
  backendset_name  = "${oci_load_balancer_backendset.this.name}"
  ip_address       = "${element(var.backend_ips, count.index)}"
  port             = "${element(var.backend_ports, count.index)}"

  // Optional
  backup  = "${element(concat(var.backup, list("false")), count.index)}"
  drain   = "${element(concat(var.drain, list("false")), count.index)}"
  offline = "${element(concat(var.offline, list("false")), count.index)}"
  weight  = "${element(concat(var.weight, list("1")), count.index)}"
}

resource "oci_load_balancer_path_route_set" "this" {
  count            = "${length(var.path_route_set_name) > 0 ? 1 : 0}"
  load_balancer_id = "${oci_load_balancer.this.id}"
  name             = "${var.path_route_set_name}"

  path_routes {
    backend_set_name = "${oci_load_balancer_backendset.this.name}"
    path             = "${var.path}"

    path_match_type {
      match_type = "${var.path_match_type}"
    }
  }
}

resource "oci_load_balancer_hostname" "this" {
  count            = "${length(var.hostnames)}"
  hostname         = "${element(var.hostnames, count.index)}"
  name             = "${element(var.hostname_names, count.index)}"
  load_balancer_id = "${oci_load_balancer.this.id}"
}

resource "oci_load_balancer_certificate" "this" {
  count              = "${length(var.listener_certificate_name) > 0 ? 1 : 0}"
  certificate_name   = "${var.listener_certificate_name}"
  load_balancer_id   = "${oci_load_balancer.this.id}"
  ca_certificate     = "${var.listener_ca_certificate}"
  passphrase         = "${var.listener_passphrase}"
  private_key        = "${var.listener_private_key}"
  public_certificate = "${var.listener_public_certificate}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "oci_load_balancer_listener" "ssl_enabled" {
  depends_on               = ["oci_load_balancer_hostname.this", "oci_load_balancer_path_route_set.this"]
  count                    = "${length(var.ssl_listener_name) > 0 ? 1 : 0}"
  default_backend_set_name = "${oci_load_balancer_backendset.this.name}"
  load_balancer_id         = "${oci_load_balancer.this.id}"
  name                     = "${var.ssl_listener_name}"
  port                     = "${var.ssl_listener_port}"
  protocol                 = "${var.listener_protocol}"

  // Optional
  hostname_names      = ["${var.ssl_listener_hostnames}"]
  path_route_set_name = "${var.ssl_listener_path_route_set}"

  ssl_configuration {
    certificate_name        = "${oci_load_balancer_certificate.this.certificate_name}"
    verify_depth            = "${var.ssl_verify_depth}"
    verify_peer_certificate = "${var.ssl_verify_peer_certificate}"
  }
}

resource "oci_load_balancer_listener" "non_ssl" {
  depends_on               = ["oci_load_balancer_hostname.this", "oci_load_balancer_path_route_set.this"]
  count                    = "${length(var.non_ssl_listener_name) > 0 ? 1 : 0}"
  default_backend_set_name = "${oci_load_balancer_backendset.this.name}"
  load_balancer_id         = "${oci_load_balancer.this.id}"
  name                     = "${var.non_ssl_listener_name}"
  port                     = "${var.non_ssl_listener_port}"
  protocol                 = "${var.listener_protocol}"

  // Optional
  hostname_names      = ["${var.non_ssl_listener_hostnames}"]
  path_route_set_name = "${var.non_ssl_listener_path_route_set}"
}
