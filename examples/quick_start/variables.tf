variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "server_ssh_authorized_keys" {}
variable "server_ssh_private_key" {}

variable "bastion_ssh_authorized_keys" {
  default = ""
}

variable "bastion_ssh_private_key" {
  default = ""
}

variable "image_id" {
  type = "map"

  # --------------------------------------------------------------------------
  # Oracle-provided image "Oracle-Linux-7.4-2018.02.21-1"
  # See https://docs.us-phoenix-1.oraclecloud.com/images/
  # --------------------------------------------------------------------------
  default = {
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaaupbfz5f5hdvejulmalhyb6goieolullgkpumorbvxlwkaowglslq"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaajlw3xfie2t5t52uegyhiq2npx7bqyu4uvi2zyu3w3mqayc2bxmaa"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa7d3fsb6272srnftyi4dphdgfjf6gurxqhmv6ileds7ba3m2gltxq"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaaa6h6gj6v4n56mqrbgnosskq63blyv2752g36zerymy63cfkojiiq"
  }
}

variable "vcn_cidr" {
  default = "10.0.0.0/16"
}

variable "server_shape" {
  default = "VM.Standard1.1"
}

variable "server_display_name" {
  description = "The display name of the nginx server"
  default     = "tfnginx"
}

variable "server_count" {
  description = "The number of the backend servers."
}

variable "http_port" {
  description = "The nginx server http port"
  default     = 80
}

variable "bastion_subnet" {
  description = "The subnet for the bastion host"
  default     = ""
}

variable "bastion_shape" {
  description = "Instance shape to use for bastion instance. "
  default     = "VM.Standard1.1"
}

variable "bastion_host_display_name" {}

variable "ssl_cert_file_path" {
  description = "The path of the ssl cert file"
}

variable "ssl_cert_key_file_path" {
  description = "The path of the ssl cert private key file"
}

variable "server_https_port" {
  description = "The https port for the nginx server"
  default     = 443
}

variable "folder_path_for_ssl_cert_files" {
  description = "The folder path on nginx server which for saving the ssl cert files"
  default     = "/etc/nginx/ssl_certs"
}