output "nginx_private_ips" {
  value = ["${module.nginx.private_ips}"]
}

output "bastion_publicIP" {
  value = "${var.bastion_host_public_ip}"
}
