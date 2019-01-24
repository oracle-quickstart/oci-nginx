package test

import (
	"../nginx_module_common"
	"../terraform-module-test-lib"
	"fmt"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"os"
	"strconv"
	"strings"
	"testing"
)

var inputs_config_file_path = "inputs_config.json"

func TestSSHPublicKeyPathInputData(t *testing.T) {

	// create dependent resources
	terraformDependenciesDir := "../dependencies"
	terraform_dependencies_options := nginx_module_common.ConfigureTerraformOptions(t, terraformDependenciesDir, inputs_config_file_path)

	testCases := []struct {
		tc_name        string
		ssh_public_key string
		output_message string
		verify_created bool
	}{
		{"ssh_public_key_with_0_char", "", "no such file or directory", false},
		{"ssh_public_key_not_exist", "/non/exist/public/ssh/key", "no such file or directory", false},
		{"ssh_public_key_exist", os.Getenv("TF_VAR_server_ssh_authorized_keys"), "Creation complete", true},
	}

	vcn_ocid, nginx_subnet_ocids_temp, bastion_subnet_ocid, _ := nginx_module_common.TestCreateVCNForNginx(t, terraform_dependencies_options)
	nginx_subnet_ocids := strings.Split(strings.Replace(nginx_subnet_ocids_temp, "\n", "", -1), ",")

	defer test_structure.RunTestStage(t, "destroy_dependencies", func() {
		logger.Log(t, "terraform destroy dependencies ...")
		terraform.Destroy(t, terraform_dependencies_options)
	})

	for _, tc := range testCases {
		t.Run(fmt.Sprintf("%s", tc.tc_name), func(t *testing.T) {
			iamTestFieldDataInputs(t, tc.ssh_public_key, tc.output_message, tc.verify_created, vcn_ocid, nginx_subnet_ocids, bastion_subnet_ocid)
		})
	}
}

func iamTestFieldDataInputs(t *testing.T, ssh_public_key string, output_message string, verify_created bool, vcn_ocid string, server_subnet_ocid []string, bastion_subnet_ocid string) {
	terraformDir := "../terraform_config_nginx_only"

	terraformOptions := nginx_module_common.ConfigureTerraformOptions(t, terraformDir, inputs_config_file_path)
	terraformOptions.Vars["vcn_ocid"] = vcn_ocid
	terraformOptions.Vars["server_subnet_ids"] = server_subnet_ocid
	terraformOptions.Vars["bastion_subnet"] = bastion_subnet_ocid
	terraformOptions.Vars["server_ssh_authorized_keys"] = ssh_public_key

	compartment_id := terraformOptions.Vars["compartment_id"].(string)

	test_structure.RunTestStage(t, "init", func() {
		fmt.Println("Starting test case...\n ")
		logger.Log(t, "terraform init ...")
		terraform.Init(t, terraformOptions)
	})

	defer test_structure.RunTestStage(t, "destroy", func() {
		if output_message == "Creation complete" {
			logger.Log(t, "terraform destroy ...")
			terraform.Destroy(t, terraformOptions)
		}
	})

	test_structure.RunTestStage(t, "apply", func() {
		logger.Log(t, "terraform apply ...")
		out, _ := terraform.ApplyE(t, terraformOptions)
		fmt.Println("Assertion......" + out)
		assert.Contains(t, out, output_message)

		if terraformOptions.Vars["server_count"].(int) <= 1 {
			resource_name := "module.nginx.module.nginx_server.oci_core_instance.this"
			display_name := terraform_module_test_lib.GetResourceProperty(t, terraformOptions, "display_name", "state", "show", resource_name)
			nginx_module_common.FindInstanceInInstancesListRestAPI(t, display_name, verify_created, compartment_id)
		} else {
			for index := 0; index < terraformOptions.Vars["server_count"].(int); index++ {
				resource_name := "module.nginx.module.nginx_server.oci_core_instance.this[" + strconv.Itoa(index) + "]"
				display_name := terraform_module_test_lib.GetResourceProperty(t, terraformOptions, "display_name", "state", "show", resource_name)
				nginx_module_common.FindInstanceInInstancesListRestAPI(t, display_name, verify_created, compartment_id)
			}
		}
	})
}
