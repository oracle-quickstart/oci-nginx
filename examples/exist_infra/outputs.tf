// Copyright (c) 2018, Oracle and/or its affiliates. All rights reserved.

output "nginx_private_ips" {
  value = ["${module.nginx.server_private_ips}"]
}

output "bastion_publicIP" {
  value = "${module.nginx.bastion_public_ip}"
}
