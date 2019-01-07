## Create Virtual Cloud Network and Deploy Load Balancer
This example shows how to deploy the nginx server(s) on Oracle Cloud Infrastructure using the Terraform module with the existing infra resources. It will create the following things:

* A bastion host to do the nginx server(s) setup 
* Nginx servers 

### Using this example
Prepare one variable file named "terraform.tfvars" with the required information. The content of "terraform.tfvars" should look something like the following:

```
$ cat terraform.tfvars
# Oracle Cloud Infrastructure authentication
tenancy_ocid = "ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
user_ocid = "ocid1.user.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
fingerprint= "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
private_key_path = "~/.oci/oci_api_key.pem"

# Region
region = "us-phoenix-1"

# Compartment
compartment_id = "ocid1.compartment.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# Instance Configration
vcn_ocid = "<vcn ocid>"
bastion_subnet = "<bastion subnet ocid>"
bastion_shape = "<bastion instance shape>"
bastion_ssh_authorized_keys = "<path to public ssh key>"
bastion_ssh_private_key = "<path to the private ssh key>"
server_count = "<the count of the nginx servers>"
server_subnet_ids = "<the list of the subnet ocids for server(s) to launch>"
server_shape = "<nginx server instance(s) shape>"
image_id = "<image ocid>"
server_http_port = "<the http port for nginx server>"
server_ssh_private_key = "<path to the private ssh key>"
server_ssh_authorized_keys = "<path to public ssh key>"
```

Please also note that the self signed certificate generated in the example is for demo purposes only.

### Run the example:

```
$ terraform init
$ terraform plan
$ terraform apply
```

### To delete all resources:

```
$ terraform destroy
```
