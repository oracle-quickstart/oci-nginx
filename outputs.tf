// Copyright (c) 2018, Oracle and/or its affiliates. All rights reserved.

output "server_instance_ids" {
  value = "${module.nginx.server_ids}"
}

output "server_private_ips" {
  value = "${module.nginx.private_ips}"
}

output "server_public_ips" {
  value = ["${module.nginx.public_ips}"]
}

output "bastion_public_ip" {
  value = ["${module.nginx.bastion_public_ip}"]
}
