output "id" {
  value = ["${oci_load_balancer.this.id}"]
}

output "ip_addresses" {
  value = ["${oci_load_balancer.this.ip_addresses}"]
}