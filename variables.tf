// Copyright (c) 2018, Oracle and/or its affiliatesAll rights reserved.

## Variables for the main.tf 
variable "compartment_ocid" {
  description = "Compartment's OCID where VCN will be created"
}

variable "vcn_ocid" {
  description = "The OCID of Virtual Cloud Network (vcn)"
}

variable "bastion_subnet" {
  description = "The subnet for the bastion host"
}

variable "bastion_shape" {
  description = "Instance shape to use for bastion instance"
  default     = "VM.Standard1.1"
}

variable "bastion_ssh_authorized_keys" {
  description = "Public SSH keys path to be included in the ~/.ssh/authorized_keys file for the default user on the bastion instance"
  default     = ""
}

variable "bastion_ssh_private_key" {
  description = "The private key path to access bastion instance"
  default     = ""
}

variable "server_count" {
  description = "Count of nginx server instance(s) to launch"
  default     = 2
}

variable "server_subnet_ids" {
  description = "The list of subnet ocids for the nginx server(s)"
  type        = "list"
}

variable "server_display_name" {
  description = "The name of the nginx server instance(s)"
  default     = "tf-nginx-server"
}

variable "server_shape" {
  description = "The shape of the nginx server instance(s)"
  default     = "VM.Standard1.1"
}

variable "server_image_id" {
  description = "The OCID of an image for server instance to use "
}

variable "server_http_port" {
  description = "The port to use for HTTP traffic to Jenkins"
  default     = 80
}

variable "server_ssh_authorized_keys" {
  description = "Public SSH keys path to be included in the ~/.ssh/authorized_keys file for the default user on the nginx server instance"
}

variable "server_ssh_private_key" {
  description = "The private key path to access nginx server instance"
}
