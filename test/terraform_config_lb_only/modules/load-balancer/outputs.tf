// Copyright (c) 2018, Oracle and/or its affiliates. All rights reserved.

output "id" {
  value = ["${oci_load_balancer.this.id}"]
}

output "ip_addresses" {
  value = ["${oci_load_balancer.this.ip_addresses}"]
}