// Copyright (c) 2018, Oracle and/or its affiliates. All rights reserved.

## DATASOURCE
locals {
  ssl_cert_filename      = "${basename(coalesce(var.ssl_cert_file_path, "/non_exsit_cert_file"))}"
  ssl_cert_key_filename  = "${basename(coalesce(var.ssl_cert_key_file_path, "/non_exsit_key_file"))}"
  ssl_cert_file_path     = "${var.folder_path_for_ssl_cert_files}/${local.ssl_cert_filename}"
  ssl_cert_key_file_path = "${var.folder_path_for_ssl_cert_files}/${local.ssl_cert_key_filename}"
}

# Init Script Files
data "template_file" "install_nginx" {
  template = "${file("${path.module}/scripts/install.sh")}"

  vars {
    http_port                      = "${coalesce(var.server_http_port, "80")}"
    https_port                     = "${coalesce(var.server_https_port, "443")}"
    folder_path_for_ssl_cert_files = "${var.folder_path_for_ssl_cert_files}"
    ssl_cert_file_path             = "${local.ssl_cert_file_path}"
    ssl_cert_key_file_path         = "${local.ssl_cert_key_file_path}"
  }
}

# Create the nginx server host(s)
module "nginx_server" {
  source                = "./modules/compute-instance"
  compartment_id        = "${var.compartment_id}"
  instance_display_name = "${var.server_display_name}"
  source_ocid           = "${var.server_image_id}"
  vcn_ocid              = "${var.vcn_ocid}"
  subnet_ocid           = "${var.server_subnet_ids}"
  ssh_authorized_keys   = "${var.server_ssh_authorized_keys}"
  assign_public_ip      = "${var.server_assign_public_ip}"
  instance_count        = "${var.server_count}"
  shape                 = "${var.server_shape}"
}

# Do the nginx server setup with Bastion Host
resource "null_resource" "setup_with_bastion" {
  depends_on = ["module.nginx_server"]
  count      = "${var.server_count}"

  triggers {
    bastion_public_ip = "${join(",",list(var.bastion_host_public_ip))}"
    server_private_ip = "${element(module.nginx_server.private_ip, count.index)}"
  }

  provisioner "file" {
    connection = {
      bastion_host        = "${var.bastion_host_public_ip}"
      bastion_host_key    = "${chomp(file(var.bastion_ssh_authorized_keys))}"
      bastion_port        = 22
      bastion_user        = "${var.bastion_host_user}"
      bastion_private_key = "${chomp(file(var.bastion_ssh_private_key))}"
      host                = "${element(module.nginx_server.private_ip, count.index)}"
      agent               = true
      timeout             = "10m"
      user                = "opc"
      private_key         = "${chomp(file(var.server_ssh_private_key))}"
    }

    source      = "${var.ssl_cert_file_path}"
    destination = "/home/opc/${local.ssl_cert_filename}"
    on_failure  = "continue"
  }

  provisioner "file" {
    connection = {
      bastion_host        = "${var.bastion_host_public_ip}"
      bastion_host_key    = "${chomp(file(var.bastion_ssh_authorized_keys))}"
      bastion_port        = 22
      bastion_user        = "${var.bastion_host_user}"
      bastion_private_key = "${chomp(file(var.bastion_ssh_private_key))}"
      host                = "${element(module.nginx_server.private_ip, count.index)}"
      agent               = true
      timeout             = "10m"
      user                = "opc"
      private_key         = "${chomp(file(var.server_ssh_private_key))}"
    }

    source      = "${var.ssl_cert_key_file_path}"
    destination = "/home/opc/${local.ssl_cert_key_filename}"
    on_failure  = "continue"
  }

  provisioner "remote-exec" {
    connection = {
      bastion_host        = "${var.bastion_host_public_ip}"
      bastion_host_key    = "${chomp(file(var.bastion_ssh_authorized_keys))}"
      bastion_port        = 22
      bastion_user        = "${var.bastion_host_user}"
      bastion_private_key = "${chomp(file(var.bastion_ssh_private_key))}"
      host                = "${element(module.nginx_server.private_ip, count.index)}"
      agent               = true
      timeout             = "10m"
      user                = "opc"
      private_key         = "${chomp(file(var.server_ssh_private_key))}"
    }

    inline = [
      "sudo mkdir -p ${var.folder_path_for_ssl_cert_files}",
      "sudo mv /home/opc/${local.ssl_cert_filename} ${local.ssl_cert_file_path}",
      "sudo mv /home/opc/${local.ssl_cert_key_filename} ${local.ssl_cert_key_file_path}",
    ]

    on_failure = "continue"
  }

  provisioner "file" {
    connection = {
      bastion_host        = "${var.bastion_host_public_ip}"
      bastion_host_key    = "${chomp(file(var.bastion_ssh_authorized_keys))}"
      bastion_port        = 22
      bastion_user        = "${var.bastion_host_user}"
      bastion_private_key = "${chomp(file(var.bastion_ssh_private_key))}"
      host                = "${element(module.nginx_server.private_ip, count.index)}"
      agent               = true
      timeout             = "10m"
      user                = "opc"
      private_key         = "${chomp(file(var.server_ssh_private_key))}"
    }

    content     = "${data.template_file.install_nginx.rendered}"
    destination = "/tmp/setup.sh"
  }

  provisioner "remote-exec" {
    connection = {
      bastion_host        = "${var.bastion_host_public_ip}"
      bastion_host_key    = "${chomp(file(var.bastion_ssh_authorized_keys))}"
      bastion_port        = 22
      bastion_user        = "${var.bastion_host_user}"
      bastion_private_key = "${chomp(file(var.bastion_ssh_private_key))}"
      host                = "${element(module.nginx_server.private_ip, count.index)}"
      agent               = true
      timeout             = "10m"
      user                = "opc"
      private_key         = "${chomp(file(var.server_ssh_private_key))}"
    }

    inline = [
      "chmod +x /tmp/setup.sh",
      "sudo /tmp/setup.sh",
    ]
  }
}
