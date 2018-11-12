## Test folder content

This directory contains test folders (folder name ends with "_test") with test cases for nginx module
divided by categories.

Folder "compute_module_helpers" contains helping functions used in multiple test cases

## How to launch test cases

Set up the following environmental variables:

- TF_VAR_tenancy_ocid=<tenancy OCID>
- TF_VAR_ssh_authorized_keys=<path to the public key>
- TF_VAR_compartment_ocid=<compartment OCID>
- TF_VAR_region=<region in which to operate, example: us-ashburn-1, us-phoenix-1>
- TF_VAR_fingerprint=<PEM key fingerprint>
- TF_VAR_private_key_path=<path to the private key that matches the fingerprint above>
- TF_VAR_instance_ssh_private_key=<path to the private key>
- TF_VAR_user_ocid=<user OCID>

The variables used in test case are in the inputs_config.json files.
The number and values of the test cases variables depend on the test case itself. They are already set up and no changes are needed.

To launch all the test cases under "test" directory, do the following:

1. Navigate to "test" directory
2. Run command: go test ./... -v -timeout 2h

To launch the test cases from the specific folder, do the following:

1. Navigate to "test" directory
2. Run command: go test -v -timeout 60m ./<folder name>/

#Example: go test -v -timeout 0m ./compute_create_Centos_instance_test/

Parameter timeout should be specified taking into consideration that:
1. One Centos, OL or Ubuntu positive test case takes about 5-7 minutes to complete
2. One Windows test cases takes about 15-17 minutes to complete