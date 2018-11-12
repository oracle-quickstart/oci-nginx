variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}

variable "vcn_cidr" {
  default = "10.0.0.0/16"
}

variable "server_count" {
  description = "The number of the backend servers."
  default     = 2
}

variable "http_port" {
  description = "The nginx server http port"
  default     = 80
}

provider "oci" {
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region           = "${var.region}"
}

data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.tenancy_ocid}"
}

# Define local variables
locals {
  tcp_protocol                     = "6"
  all_protocol                     = "all"
  anywhere                         = "0.0.0.0/0"
  dmz_tier_prefix                  = "${cidrsubnet(var.vcn_cidr, 4, 0)}"
  app_tier_prefix                  = "${cidrsubnet(var.vcn_cidr, 4, 1)}"
  nginx_subnet_prefix              = "${cidrsubnet("${local.dmz_tier_prefix}", 4, 2)}"
  bs_subnet_prefix                 = "${cidrsubnet("${local.app_tier_prefix}", 4, 1)}"
  lb_subnet_prefix                 = "${cidrsubnet("${local.app_tier_prefix}", 4, 0)}"
  bs_availability_domain           = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")}"
  lb_subnet_count                  = "${min(length(data.oci_identity_availability_domains.ADs.availability_domains),var.server_count)}"
  NATGW_id_temp_file_name          = ".oci_core_route_table.with_NATGW.id"
  bastion_subnet_id_temp_file_name = ".oci_core_subnet.bastion.id"
}

resource "oci_core_virtual_network" "AutoNginxModuleTestVCN" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "AutoNginxModuleTestVCN"
  dns_label      = "actestvcn"
}

resource "oci_core_internet_gateway" "AutoNginxModuleTestIG" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "AutoNginxModuleTestIG"
  vcn_id         = "${oci_core_virtual_network.AutoNginxModuleTestVCN.id}"
}

resource "oci_core_route_table" "AutoNginxModuleTestRTwithIG" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.AutoNginxModuleTestVCN.id}"
  display_name   = "AutoNginxModuleTestRouteTableWithIG"

  route_rules {
    cidr_block = "0.0.0.0/0"

    # Internet Gateway route target for instances on public subnets
    network_entity_id = "${oci_core_internet_gateway.AutoNginxModuleTestIG.id}"
  }
}

# Create a NAT gateway when using the bastion to do the setup 
resource "oci_core_nat_gateway" "AutoNginxModuleTestNATGW" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.AutoNginxModuleTestVCN.id}"
  display_name   = "AutoNginxModuleTestNATGW"
}

# Create a Route Table resource for the Virtual Cloud Network and configured with the created NAT Gateway 
resource "oci_core_route_table" "AutoNginxModuleTestRouteTableWithNATGW" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.AutoNginxModuleTestVCN.id}"
  display_name   = "AutoNginxModuleTestRouteTableWithNATGW"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = "${oci_core_nat_gateway.AutoNginxModuleTestNATGW.id}"
  }
}

# Create a security list for ssh port
resource "oci_core_security_list" "AutoNginxModuleTestSSHSeclist" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "AutoNginxModuleTestSSHSeclist"
  vcn_id         = "${oci_core_virtual_network.AutoNginxModuleTestVCN.id}"

  egress_security_rules = [{
    protocol    = "${local.all_protocol}"
    destination = "${local.anywhere}"
  }]

  ingress_security_rules = [
    {
      protocol = "${local.tcp_protocol}"
      source   = "${local.anywhere}"

      tcp_options {
        "min" = 22
        "max" = 22
      }
    },
  ]
}

# Create a security list for http port
resource "oci_core_security_list" "AutoNginxModuleTestHTTPSeclist" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "AutoNginxModuleTestHTTPSeclist"
  vcn_id         = "${oci_core_virtual_network.AutoNginxModuleTestVCN.id}"

  egress_security_rules = [{
    protocol    = "${local.all_protocol}"
    destination = "${local.anywhere}"
  }]

  ingress_security_rules = [{
    protocol = "${local.tcp_protocol}"
    source   = "${local.anywhere}"

    tcp_options {
      "min" = "${var.http_port}"
      "max" = "${var.http_port}"
    }
  }]
}


# Create Subnet resource 
resource "oci_core_subnet" "AutoNginxModuleTestSubnetNginx" {
  # every AD has a lb subnet, also need check the number of the nginx server counts
  count               = "${max(length(data.oci_identity_availability_domains.ADs.availability_domains),var.server_count)}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index], "name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "AutoNginxModuleTestSubnetNginx{count.index}"
  cidr_block          = "${cidrsubnet(local.nginx_subnet_prefix, 4, count.index)}"
  security_list_ids   = ["${oci_core_security_list.AutoNginxModuleTestHTTPSeclist.id}", "${oci_core_security_list.AutoNginxModuleTestSSHSeclist.id}"]
  vcn_id              = "${oci_core_virtual_network.AutoNginxModuleTestVCN.id}"
  route_table_id      = "${oci_core_route_table.AutoNginxModuleTestRouteTableWithNATGW.id}"
}

# Create the subnet for bastion host
resource "oci_core_subnet" "AutoNginxModuleTestSubnetBastion" {
  availability_domain = "${local.bs_availability_domain}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "AutoNginxModuleTestSubnetBastion"
  cidr_block          = "${local.bs_subnet_prefix}"
  security_list_ids   = ["${oci_core_security_list.AutoNginxModuleTestSSHSeclist.id}"]
  vcn_id              = "${oci_core_virtual_network.AutoNginxModuleTestVCN.id}"
  route_table_id      = "${oci_core_route_table.AutoNginxModuleTestRTwithIG.id}"
}

# Create the subnets for load balance
resource "oci_core_subnet" "AutoNginxModuleTestSubnetLB" {
  count               = 2
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index], "name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "AutoNginxModuleTestSubnetLB-${count.index}"
  cidr_block          = "${cidrsubnet(local.lb_subnet_prefix, 4, count.index)}"
  security_list_ids   = ["${oci_core_security_list.AutoNginxModuleTestHTTPSeclist.id}"]
  vcn_id              = "${oci_core_virtual_network.AutoNginxModuleTestVCN.id}"
  route_table_id      = "${oci_core_route_table.AutoNginxModuleTestRTwithIG.id}"
}

//resource "oci_core_subnet" "AutoNginxModuleTestSubnet" {
//  count               = "${length(data.oci_identity_availability_domains.ADs.availability_domains)}"
//  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index],"name")}"
//  cidr_block          = "${cidrsubnet("10.0.0.0/16", 4, count.index)}"
//  display_name        = "AutoNginxModuleTestSubnet-${count.index}"
//  dns_label           = "actestsubnet${count.index}"
//  compartment_id      = "${var.compartment_ocid}"
//  vcn_id              = "${oci_core_virtual_network.AutoNginxModuleTestVCN.id}"
//  security_list_ids   = ["${oci_core_virtual_network.AutoNginxModuleTestVCN.default_security_list_id}"]
//  route_table_id      = "${oci_core_route_table.AutoNginxModuleTestRT.id}"
//  dhcp_options_id     = "${oci_core_virtual_network.AutoNginxModuleTestVCN.default_dhcp_options_id}"
//}

output "vcn_ocid" {
  value = "${oci_core_virtual_network.AutoNginxModuleTestVCN.id}"
}

output "nginx_subnet_ocids" {
  value = ["${oci_core_subnet.AutoNginxModuleTestSubnetNginx.*.id}"]
}

output "bastion_subnet_ocid" {
  value = ["${oci_core_subnet.AutoNginxModuleTestSubnetBastion.*.id}"]
}

output "lb_subnet_ocid" {
  value = ["${oci_core_subnet.AutoNginxModuleTestSubnetLB.*.id}"]
}