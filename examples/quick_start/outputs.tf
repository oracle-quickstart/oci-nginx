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

output "ssh_authorized_keys" {
  value = "${path.module}/${local_file.ssh_public_key.filename}"
}

output "ssh_private_key" {
  value = "${path.module}/${local_file.ssh_private_key.filename}"
}

output "bastion_private_key" {
  value = "${path.module}/${local_file.ssh_private_key.filename}"
}

output "bastion_authorized_keys" {
  value = "${path.module}/${local_file.ssh_public_key.filename}"
}