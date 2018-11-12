**Note:** This module is currently available for internal-Oracle consumption as part of a Limited Availability release. See [Oracle Cloud Infrastructure Terraform Modules](https://confluence.oraclecorp.com/confluence/display/BMCS/OCI+Terraform+Modules) for information about how to use this module and how to give feedback.

# Oracle Cloud Infrastructure Nginx Terraform Module

The Oracle Cloud Infrastructure Nginx Terraform Module provides an easy way set up Nginx server(s) on Oracle Cloud Infrastructure with or without Oracle Cloud Infrastructure Local Balancer with multiple backends, health checks, listeners, and other features, using sensible defaults and a simplified interface. For information about Oracle Cloud Infrastructure Local Balancer, see [Overview of Load Balancing](https://docs.cloud.oracle.com/iaas/Content/Balance/Concepts/balanceoverview.htm).


## Prerequisites

1. [Download and install Terraform](https://www.terraform.io/downloads.html) (v0.11.8 or later)
2. [Download and install the Oracle Cloud Infrastructure Terraform Provider](https://github.com/oracle/terraform-provider-oci) (v3.5.0 or later)

## How to Use the Module

The following example

```hcl
module "nginx" {
    source                      = "../"
    compartment_ocid            = "${var.compartment_ocid}"
    vcn_ocid                    = "${var.vcn_ocid}"
    bastion_subnet              = "${var.bastion_subnet}"
    bastion_shape               = "${var.bastion_shape}"
    server_count                = "${var.server_count}"
    server_subnet_ids           = "${var.server_subnet_ids}"
    server_display_name         = "${var.server_display_name}"
    server_shape                = "${var.server_shape}"
    server_image_id             = "${var.server_image_id}"
    server_http_port            = "${var.server_http_port}"
    server_ssh_authorized_keys  = "${var.server_ssh_authorized_keys}"
    server_ssh_private_key      = "${var.server_ssh_private_key}"
}
```

**Following are arguments available to the Nginx module:**

Argument | Description
--- | ---
server_http_port | The http port of the nginx server(s).
compartment_id | Unique identifier (OCID) of the compartment in which to create the Nginx server(s).
bastion_host_display_name | The display name of the bastion host instance.
bastion_image_id | The Unique identifier (OCID) of the image which will be used to create the bastion host.
vcn_ocid | Unique identifier (OCID) of the VCN in which to create the Nginx server(s).
bastion_subnet | The Unique identifier (OCID) of the subnet which the bastion host will be created.
bastion_ssh_authorized_keys | The path of public SSH key for the bastion host.
bastion_ssh_private_key | The path of private SSH key to access bastion instance
bastion_shape | The shape for the bastion host instance.
server_display_name | The display name of the nginx server(s).
server_image_id | The Unique identifier (OCID) of the image which will be used to create the nginx server(s).
server_subnet_ids | The list of the Unique identifiers (OCIDs) of the subnet in which to create the nginx server(s).
server_assign_public_ip | Whether the VNIC of the nginx server(s) should be assigned a public IP address.
server_count | The count of the nginx server(s) to be created.
server_shape | The shape for the nginx server instance(s).
server_ssh_authorized_keys | The path of public SSH key for the nginx server(s).
server_ssh_private_key | The path of private SSH key to access the nginx server(3)
server_https_port | The https port for the nginx server
folder_path_for_ssl_cert_files | The folder path on nginx server which for saving the ssl cert files
ssl_cert_file_path | The path of the ssl cert file
ssl_cert_key_file_path | The path of the ssl cert private key file

## Contributing

This project is open source. Oracle appreciates any contributions that are made by the open source community.

## License

Copyright (c) 2018, Oracle and/or its affiliates. All rights reserved.

This SDK and sample is dual licensed under the Universal Permissive License 1.0 and the Apache License 2.0.
Licensed under the Universal Permissive License 1.0 or Apache License 2.0.

See [LICENSE](/LICENSE.txt) for more details.
