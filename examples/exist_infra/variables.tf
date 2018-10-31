variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "compartment_ocid" {}
variable "vcn_ocid" {}
variable "server_ssh_authorized_keys" {}
variable "server_ssh_private_key" {}

variable "bastion_ssh_authorized_keys" {
  default = ""
}

variable "bastion_ssh_private_key" {
  default = ""
}

variable "image_id" {}

variable "vcn_cidr" {
  default = "10.0.0.0/16"
}

variable "server_shape" {
  default = "VM.Standard1.1"
}

variable "assign_public_ip" {
  default = true
}

variable "server_display_name_prefix" {
  description = "The display name of the nginx server"
  default     = "tfnginx"
}

variable "server_count" {
  description = "The number of the backend servers."
}

variable "server_subnet_ids" {}

variable "http_port" {
  description = "The nginx server http port"
  default     = 80
}

variable "bastion_subnet" {
  description = "The subnet for the bastion host"
}

variable "bastion_shape" {
  description = "Instance shape to use for bastion instance. "
  default     = "VM.Standard1.1"
}
