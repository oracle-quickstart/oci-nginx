// Copyright (c) 2018, Oracle and/or its affiliates. All rights reserved.

output "server_ids" {
  value = "${module.nginx_server.instance_id}"
}

output "private_ips" {
  value = "${module.nginx_server.private_ip}"
}

output "bastion_public_ip" {
  value = "${module.bastion_host.public_ip}"
}
