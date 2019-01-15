// Copyright (c) 2018, Oracle and/or its affiliates. All rights reserved.

output "nginx_private_ips" {
  value = ["${module.nginx.private_ips}"]
}

output "nginx_subnets" {
  value = ["${oci_core_subnet.nginx.*.cidr_block}"]
}

output "bastion_publicIP" {
  value = "${module.nginx.bastion_public_ip}"
}

output "load_balance_endpoint" {
  value = "${module.load_balancer.ip_addresses}"
}

output "server_http_port" {
  value = "${module.nginx.server_http_port}"
}