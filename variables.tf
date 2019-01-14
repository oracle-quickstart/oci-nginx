// Copyright (c) 2018, Oracle and/or its affiliatesAll rights reserved.
variable "ssl_cert_file_path" {
  description = "The path of the ssl cert file"
}

variable "ssl_cert_key_file_path" {
  description = "The path of the ssl cert private key file"
}

variable "server_http_port" {
  description = "The http port for the nginx server"
}

variable "server_https_port" {
  description = "The https port for the nginx server"
}

variable "folder_path_for_ssl_cert_files" {
  description = "The folder path on nginx server which for saving the ssl cert files"
  default     = "/etc/pki/nginx"
}

variable "compartment_id" {
  description = "Compartment's OCID where VCN will be created"
}

variable "vcn_ocid" {
  description = "VCN's OCID "
}

variable "bastion_host_public_ip" {
  description = "The public IP of bastion host"
}

variable "bastion_host_user" {
  description = "The user name of bastion host"
  default = "opc"
}

variable "bastion_ssh_authorized_keys" {
  description = "Public SSH keys path to be included in the ~/.ssh/authorized_keys file for the default user on the bastion instance"
}

variable "bastion_ssh_private_key" {
  description = "The private key path to access bastion instance"
}

variable "server_ssh_authorized_keys" {
  description = "Public SSH keys path to be included in the ~/.ssh/authorized_keys file for the default user on the nginx server(s) instance"
}

variable "server_display_name" {
  description = "The display name of the nginx server instance"
  default     = "nginx_server"
}

variable "server_image_id" {
  description = "The OCID of an image for server instance to use "
}

variable "server_subnet_ids" {
  description = "List of nginx server subnets' id"
  type        = "list"
}

variable "server_assign_public_ip" {
  description = "Whether the VNIC of nginx server should be assigned a public IP address"
  default     = false
}

variable "server_count" {
  description = "Number of nginx server instances to launch"
}

variable "server_shape" {
  description = "Instance shape to use for nginx server instance"
  default     = "VM.Standard2.1"
}

variable "server_ssh_private_key" {
  description = "The private key path to access nginx server(s) instance"
}
