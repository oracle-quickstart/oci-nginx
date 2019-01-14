variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "compartment_id" {}
variable "vcn_ocid" {}
variable "server_ssh_authorized_keys" {}
variable "server_ssh_private_key" {}

variable "bastion_ssh_authorized_keys" {}

variable "bastion_ssh_private_key" {}

variable "image_id" {}

variable "server_shape" {
  default = "VM.Standard2.1"
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

variable "bastion_host_user" {
  description = "The user name of bastion host"
  default     = "opc"
}

variable "bastion_host_public_ip" {
  description = "The public IP of bastion host"
}

variable "ssl_cert_file_path" {
  description = "The path of the ssl cert file"
}

variable "ssl_cert_key_file_path" {
  description = "The path of the ssl cert private key file"
}
