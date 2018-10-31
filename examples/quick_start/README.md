## Create Virtual Cloud Network and Deploy Load Balancer
This example shows how to deploy the nginx servers with public Load Balancer on Oracle Cloud Infrastructure using the Terraform module. It will create the following things:

* A virtual cloud network with two subnets (each in a different availability domain) and an internet gateway
* Two nginx servers running (in different subnets)
* A bastion host to setup the nginx servers
* A public load balancer

![nginx_quick_start_example](./images/nginx_quick_start_example.png)

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
compartment_ocid = "ocid1.compartment.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# Instance Configration
ssh_authorized_keys = "~/.ssh/id_rsa.pub"
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
