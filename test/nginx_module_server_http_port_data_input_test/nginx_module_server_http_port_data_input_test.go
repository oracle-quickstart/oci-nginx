package test

import (
	"../nginx_module_common"
	"fmt"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"net/http"
	"strconv"
	"strings"
	"terraform-module-test-lib"
	"testing"
	"time"
	"io/ioutil"
)

var inputs_config_file_path = "inputs_config.json"

func TestServerHTTPPortInputData(t *testing.T) {
	testCases := []struct {
		tc_name          string
		server_http_port string
		output_message   string
		verify_created   bool
	}{
		{"server_http_port_empty", "", "Creation complete", true},
		{"server_http_port_80", "80", "Creation complete", true},
		//{"server_http_port_8080", "8080", "Creation complete", true},
		//{"server_http_port_8088", "8088", "Creation complete", true},
	}

	// create dependent resources
	terraformDependenciesDir := "../dependencies"
	terraform_dependencies_options := nginx_module_common.ConfigureTerraformOptions(t, terraformDependenciesDir, inputs_config_file_path)

	vcn_ocid, nginx_subnet_ocids_temp, bastion_subnet_ocid, lb_subnet_ocid_temp := nginx_module_common.TestCreateVCNForNginx(t, terraform_dependencies_options)
	nginx_subnet_ocids := strings.Split(strings.Replace(nginx_subnet_ocids_temp, "\n", "", -1), ",")
	lb_subnet_ocids := strings.Split(strings.Replace(lb_subnet_ocid_temp, "\n", "", -1), ",")

	defer test_structure.RunTestStage(t, "destroy_dependencies", func() {
		logger.Log(t, "terraform destroy dependencies ...")
		terraform.Destroy(t, terraform_dependencies_options)
	})

	for _, tc := range testCases {
		t.Run(fmt.Sprintf("%s", tc.tc_name), func(t *testing.T) {
			serverPortDataInputs(t, tc.server_http_port, tc.output_message, tc.verify_created, vcn_ocid, nginx_subnet_ocids, bastion_subnet_ocid, lb_subnet_ocids)
		})
	}
}

func serverPortDataInputs(t *testing.T, server_http_port string, output_message string, verify_created bool, vcn_ocid string, server_subnet_ocid []string, bastion_subnet_ocid string, lb_subnet_ids []string) {
	terraformDir := "../terraform_config_nginx_only"

	terraformOptions := nginx_module_common.ConfigureTerraformOptions(t, terraformDir, inputs_config_file_path)
	terraformOptions.Vars["vcn_ocid"] = vcn_ocid
	terraformOptions.Vars["server_subnet_ids"] = server_subnet_ocid
	terraformOptions.Vars["bastion_subnet"] = bastion_subnet_ocid
	terraformOptions.Vars["server_http_port"] = server_http_port

	compartment_id := terraformOptions.Vars["compartment_ocid"].(string)

	test_structure.RunTestStage(t, "init", func() {
		fmt.Println("Starting test case...\n ")
		logger.Log(t, "terraform init ...")
		terraform.Init(t, terraformOptions)
	})

	defer test_structure.RunTestStage(t, "destroy", func() {
		logger.Log(t, "terraform destroy ...")
		terraform.Destroy(t, terraformOptions)
	})

	lb_backend_ips := []string{}
	test_structure.RunTestStage(t, "apply", func() {
		logger.Log(t, "terraform apply ...")
		out, _ := terraform.ApplyE(t, terraformOptions)
		fmt.Println("Assertion......")
		assert.Contains(t, out, output_message)

		if terraformOptions.Vars["server_count"].(int) <= 1 {
			resource_name := "module.nginx.module.nginx_server.oci_core_instance.this"
			display_name := test_helper.GetResourceProperty(t, terraformOptions, "display_name", "state", "show", resource_name)
			nginx_module_common.FindInstanceInInstancesListRestAPI(t, display_name, verify_created, compartment_id)

		} else {
			for index := 0; index < terraformOptions.Vars["server_count"].(int); index++ {
				resource_name := "module.nginx.module.nginx_server.oci_core_instance.this[" + strconv.Itoa(index) + "]"
				display_name := test_helper.GetResourceProperty(t, terraformOptions, "display_name", "state", "show", resource_name)
				nginx_module_common.FindInstanceInInstancesListRestAPI(t, display_name, verify_created, compartment_id)
			}
		}

		lb_backend_ips_temp := terraform.Output(t, terraformOptions, "nginx_server_private_ips")
		if terraformOptions.Vars["server_count"].(int) <= 1 {
			lb_backend_ips = append(lb_backend_ips, strings.Replace(lb_backend_ips_temp, "\n", "", -1))
		} else {
			lb_backend_ips = strings.Split(strings.Replace(lb_backend_ips_temp, "\n", "", -1), ",")
		}
		server_port_from_output := terraform.Output(t, terraformOptions, "server_http_port")
		lbEndpointTest(t, server_port_from_output, output_message, vcn_ocid, lb_subnet_ids, lb_backend_ips)
	})
}

func lbEndpointTest(t *testing.T, server_port string, output_message string, vcn_ocid string, lb_subnet_ids []string, lb_backend_ips []string) {
	terraformDir := "../terraform_config_lb_only"

	terraformOptions := nginx_module_common.ConfigureTerraformOptions(t, terraformDir, inputs_config_file_path)
	terraformOptions.Vars["vcn_ocid"] = vcn_ocid
	terraformOptions.Vars["lb_subnet_ids"] = lb_subnet_ids
	terraformOptions.Vars["backend_ips"] = lb_backend_ips
	terraformOptions.Vars["backend_count"] = terraformOptions.Vars["server_count"]
	terraformOptions.Vars["server_http_port"] = server_port

	test_structure.RunTestStage(t, "init", func() {
		fmt.Println("Starting test case...\n ")
		logger.Log(t, "terraform init ...")
		terraform.Init(t, terraformOptions)
	})

	defer test_structure.RunTestStage(t, "destroy", func() {
		logger.Log(t, "terraform destroy ...")
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "apply", func() {
		logger.Log(t, "terraform apply ...")
		out, _ := terraform.ApplyE(t, terraformOptions)
		fmt.Println("Assertion......")
		assert.Contains(t, out, output_message)

		lb_endpoint := terraform.Output(t, terraformOptions, "lb_endpoint")

		http_url := "http://" + lb_endpoint + ":" + server_port

		//# Check the lb endpoint is working
		for i := 0; i < 30; i++ {
			fmt.Println("Sleep 10 seconds to continue to check : " + http_url)
			time.Sleep(10 * time.Second)
			resp, err := http.Get(http_url)
			bodyBytes, _ := ioutil.ReadAll(resp.Body)
			bodyString := string(bodyBytes)
			if assert.EqualValues(t, http.StatusOK, resp.StatusCode) {
				fmt.Println("Success ! Response Status: " + resp.Status)
				fmt.Println("Success ! Response Body: " + bodyString)
				break
			} else {
				fmt.Println("Failed ! Response Status: " + resp.Status)
				fmt.Println("Failed ! Response Body: " + bodyString)
				fmt.Println("ERR: " + err.Error())
			}
		}

	})
}
