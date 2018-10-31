// Copyright (c) 2018, Oracle and/or its affiliates. All rights reserved.

variable "compartment_id" {
  description = "The OCID of the Compartment to create the load balancer in."
}

variable "display_name" {
  description = "The display name of the load balancer."
}

variable "shape" {
  description = "The shape of the load balancer."
  default     = "100Mbps"
}

variable "subnet_ids" {
  description = "The list of subnet ids to host the load balancer."
  type        = "list"
}

variable "is_private" {
  description = "To create a public or private load balancer."
  default     = false
}

variable "backendset_name" {
  description = "The name of the backendset."
}

variable "backendset_policy" {
  description = "The load balancer policy for the backend set."
}

variable "hc_protocol" {
  description = "The health checker protocol."
}

variable "hc_port" {
  description = "The backend server port against which to run the health check."
}

variable "hc_interval_ms" {
  description = "Specify how frequently to run the health check."
  default     = 30000
}

variable "hc_retries" {
  description = "The number of retries to attempt before a backend server is considered unhealthy."
  default     = 3
}

variable "hc_return_code" {
  description = "The status code a healthy backend server must return."
  default     = 200
}

variable "hc_timeout_in_millis" {
  description = "The maximum time in milliseconds to wait for a reply to a health check."
  default     = 3000
}

variable "hc_response_body_regex" {
  description = "A regular expression for parsing the response body from the backend server."
  default     = ""
}

variable "hc_url_path" {
  description = "A URL endpoint against which to run the health check."
  default     = ""
}

variable "backend_count" {
  description = "The number of the backend servers."
}

variable "backend_ips" {
  description = "The IP addresses of the backend servers."
  type        = "list"
}

variable "backend_ports" {
  description = "The communication port for the backend server."
  type        = "list"
}

variable "backup" {
  description = "Whether the load balancer should treat this server as a backup unit."
  default     = []
}

variable "drain" {
  description = "Whether the load balancer should drain this server."
  default     = []
}

variable "offline" {
  description = "Whether the load balancer should treat this server as offline."
  default     = []
}

variable "weight" {
  description = "The load balancing policy weight assigned to the server."
  default     = []
}

variable "path_route_set_name" {
  description = "The name of the set of path-based routing rules."
  default     = ""
}

variable "path" {
  description = "The path string to match against the incoming URI path."
  default     = ""
}

variable "path_match_type" {
  description = "The type of matching to apply to incoming URIs."
  default     = ""
}

variable "hostnames" {
  description = "A list of virtual hostnames."
  default     = []
}

variable "hostname_names" {
  description = "A list of friendly name for the hostname resources."
  default     = []
}

variable "listener_certificate_name" {
  description = "The friendly name of the SSL certificate for listener."
  default     = ""
}

variable "listener_ca_certificate" {
  description = "The associated Certificate Authority certificate."
  default     = ""
}

variable "listener_passphrase" {
  description = "The passphrase for the certificate."
  default     = ""
}

variable "listener_private_key" {
  description = "The private key for the certificate."
  default     = ""
}

variable "listener_public_certificate" {
  description = "The certificate in PEM format."
  default     = ""
}

variable "listener_protocol" {
  description = "The protocol on which the listener accepts connection requests, either HTTP or TCP."
}

variable "ssl_listener_name" {
  description = "The name of the listener with ssl enabled."
  default     = ""
}

variable "ssl_listener_port" {
  description = "The communication port for the listener with ssl enabled."
  default     = ""
}

variable "ssl_verify_peer_certificate" {
  description = "To enable peer certificate verification."
  default     = true
}

variable "ssl_verify_depth" {
  description = "The maximum depth for certificate chain verification."
  default     = 5
}

variable "ssl_listener_hostnames" {
  description = "The hostname resources for the listener with ssl enabled."
  default     = []
}

variable "ssl_listener_path_route_set" {
  description = "The path route set name for the listener with ssl enabled. It applys only to HTTP and HTTPS requests."
  default     = ""
}

variable "non_ssl_listener_name" {
  description = "The name of the listener without ssl enabled."
  default     = ""
}

variable "non_ssl_listener_port" {
  description = "The communication port for the listener without ssl enabled."
  default     = ""
}

variable "non_ssl_listener_hostnames" {
  description = "The hostname resources for the listener without ssl enabled."
  default     = []
}

variable "non_ssl_listener_path_route_set" {
  description = "The path route set name for the listener without ssl enabled. It applys only to HTTP and HTTPS requests."
  default     = ""
}