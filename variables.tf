// Copyright (c) 2018, Oracle and/or its affiliatesAll rights reserved.

variable "server_http_port" {
  description = "The http port for the nginx server"
  default     = 80
}

variable "compartment_ocid" {
  description = "Compartment's OCID where VCN will be created"
}

variable "bastion_host_display_name" {
  description = "The display name of the nginx server instance"
  default     = "bastion_host_for_nginx_server"
}

variable "bastion_image_id" {
  description = "The OCID of an image for bastion host to use "
  default     = ""
}

variable "vcn_ocid" {
  description = "VCN's OCID "
}

variable "bastion_subnet" {
  description = "The subnet for the bastion host"
}

variable "bastion_ssh_authorized_keys" {
  description = "Public SSH keys path to be included in the ~/.ssh/authorized_keys file for the default user on the bastion instance"
  default     = ""
}

variable "bastion_ssh_private_key" {
  description = "The private key path to access bastion instance"
  default     = ""
}

variable "server_ssh_authorized_keys" {
  description = "Public SSH keys path to be included in the ~/.ssh/authorized_keys file for the default user on the nginx server(s) instance"
}

variable "bastion_shape" {
  description = "Shape for bastion instance"
  default     = "VM.Standard1.1"
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
  description = "Whether the VNIC should be assigned a public IP address"
  default     = false
}

variable "server_count" {
  description = "Number of nginx server instances to launch"
}

variable "server_shape" {
  description = "Instance shape to use for nginx server instance"
  default     = "VM.Standard1.1"
}

variable "server_ssh_private_key" {
  description = "The private key path to access nginx server(s) instance"
}
