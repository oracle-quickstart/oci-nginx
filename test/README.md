## Test folder content

This directory contains test folders (folder name ends with "_test") with test cases for nginx module
divided by categories.

Folder "nginx_module_common" contains helping functions used in multiple test cases

## How to launch test cases

Set up the following environmental variables:

- TF_VAR_tenancy_ocid=<tenancy OCID>
- TF_VAR_server_ssh_authorized_keys=<path to the public key>
- TF_VAR_compartment_id=<compartment OCID>
- TF_VAR_region=<region in which to operate, example: us-ashburn-1, us-phoenix-1>
- TF_VAR_fingerprint=<PEM key fingerprint>
- TF_VAR_private_key_path=<path to the private key that matches the fingerprint above>
- TF_VAR_server_ssh_private_key=<path to the private key>
- TF_VAR_user_ocid=<user OCID>

The variables used in test case are in the inputs_config.json files.
The number and values of the test cases variables depend on the test case itself, please change them accordingly if necessary.

To launch all the test cases under "test" directory, do the following:

1. Navigate to "test" directory
2. Run command: go test ./... -v -timeout 2h

To launch the test cases from the specific folder, do the following:

1. Navigate to "test" directory
2. Run command: go test -v -timeout 60m ./<folder name>/

```bash
#Example: go test -v -timeout 60m ./nginx_module_displayName_data_input_test/
```
