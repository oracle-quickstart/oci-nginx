package nginx_module_common

import (
	"context"
	"fmt"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/oracle/oci-go-sdk/common"
	"github.com/oracle/oci-go-sdk/core"
	"github.com/stretchr/testify/assert"
	"os"
	"terraform-module-test-lib"
	"testing"
)

type Inputs struct {
	Tenancy_ocid                string        `json:"tenancy_ocid"`
	Compartment_ocid            string        `json:"compartment_ocid"`
	User_ocid                   string        `json:"user_ocid"`
	Region                      string        `json:"region"`
	Fingerprint                 string        `json:"fingerprint"`
	Private_key_path            string        `json:"private_key_path"`
	Vcn_ocid                    string        `json:"vcn_ocid"`
	Bastion_subnet              string        `json:"bastion_subnet"`
	Bastion_shape               string        `json:"bastion_shape"`
	Bastion_ssh_authorized_keys string        `json:"bastion_ssh_authorized_keys"`
	Bastion_ssh_private_key     string        `json:"bastion_ssh_private_key"`
	Bastion_host_display_name   string        `json:"bastion_host_display_name"`
	Bastion_image_id            string        `json:"bastion_image_id"`
	Server_count                int           `json:"server_count"`
	Server_subnet_ids           []interface{} `json:"server_subnet_ids"`
	Server_display_name         string        `json:"server_display_name"`
	Server_shape                string        `json:"server_shape"`
	Server_image_id             string        `json:"server_image_id"`
	Server_http_port            string        `json:"server_http_port"`
	Server_ssh_authorized_keys  string        `json:"server_ssh_authorized_keys"`
	Server_ssh_private_key      string        `json:"server_ssh_private_key"`
	Lb_subnet_ids               string        `json:"lb_subnet_ids"`
	Backend_ips                 []interface{} `json:"backend_ips"`
	Backend_count               int           `json:"backend_count"`
	Hc_port                     string        `json:"hc_port"`
	Backend_ports               []interface{} `json:"backend_ports"`
	Non_ssl_listener_port       string        `json:"non_ssl_listener_port"`
}

func ConfigureTerraformOptions(t *testing.T, terraformDir string, input_file_path string) *terraform.Options {
	var vars Inputs
	err := test_helper.GetConfig(input_file_path, &vars)
	if err != nil {
		logger.Logf(t, err.Error())
		t.Fail()
	}
	terraformOptions := &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"tenancy_ocid":                os.Getenv("TF_VAR_tenancy_ocid"),
			"compartment_ocid":            os.Getenv("TF_VAR_compartment_ocid"),
			"user_ocid":                   os.Getenv("TF_VAR_user_ocid"),
			"region":                      os.Getenv("TF_VAR_region"),
			"fingerprint":                 os.Getenv("TF_VAR_fingerprint"),
			"private_key_path":            os.Getenv("TF_VAR_private_key_path"),
			"vcn_ocid":                    vars.Vcn_ocid,
			"bastion_subnet":              vars.Bastion_subnet,
			"bastion_shape":               vars.Bastion_shape,
			"bastion_ssh_authorized_keys": vars.Bastion_ssh_authorized_keys,
			"bastion_ssh_private_key":     vars.Bastion_ssh_private_key,
			"bastion_host_display_name":   vars.Bastion_host_display_name,
			"bastion_image_id":            vars.Bastion_image_id,
			"server_count":                vars.Server_count,
			"server_subnet_ids":           vars.Server_subnet_ids,
			"server_display_name":         vars.Server_display_name,
			"server_shape":                vars.Server_shape,
			"server_image_id":             vars.Server_image_id,
			"server_http_port":            vars.Server_http_port,
			"server_ssh_authorized_keys":  os.Getenv("TF_VAR_server_ssh_authorized_keys"),
			"server_ssh_private_key":      os.Getenv("TF_VAR_server_ssh_private_key"),
			"lb_subnet_ids":               vars.Lb_subnet_ids,
			"backend_ips":                 vars.Backend_ips,
			"backend_count":               vars.Backend_count,
			"hc_port":                     vars.Hc_port,
			"backend_ports":               vars.Backend_ports,
			"non_ssl_listener_port":       vars.Non_ssl_listener_port,
		},
		Upgrade: true,
	}
	return terraformOptions
}

func CreateComputeClient() (context.Context, core.ComputeClient) {
	ctx := context.Background()

	c, err := core.NewComputeClientWithConfigurationProvider(common.DefaultConfigProvider())
	if err != nil {
		fmt.Println(err)
	}
	return ctx, c
}

func TestListInstancies(ctx context.Context, c core.ComputeClient, compartment_id string) []core.Instance {
	request := core.ListInstancesRequest{
		CompartmentId: common.String(compartment_id),
	}
	r, err := c.ListInstances(ctx, request)
	if err != nil {
		fmt.Println(err)
	}
	return r.Items
}

func TestGetInstanceId(ctx context.Context, c core.ComputeClient, instance_name string, compartment_id string) string {
	var instance_id string
	for _, element := range TestListInstancies(ctx, c, compartment_id) {
		if *element.DisplayName == instance_name {
			instance_id = *element.Id
		}
	}
	return instance_id
}

func TestListVolumeAttachments(ctx context.Context, c core.ComputeClient, instance_id string, compartment_id string) []core.VolumeAttachment {
	request := core.ListVolumeAttachmentsRequest{
		CompartmentId: common.String(compartment_id),
		InstanceId:    common.String(instance_id),
	}
	r, err := c.ListVolumeAttachments(ctx, request)
	if err != nil {
		fmt.Println(err)
	}
	return r.Items
}

func TestGetVolumeAttachmentState(ctx context.Context, c core.ComputeClient, instance_id string, compartment_id string) core.VolumeAttachmentLifecycleStateEnum {
	var state core.VolumeAttachmentLifecycleStateEnum
	for _, element := range TestListVolumeAttachments(ctx, c, instance_id, compartment_id) {
		state = element.GetLifecycleState()
	}
	return state
}

func TestCreateVCNForNginx(t *testing.T, terraform_dependencies_options *terraform.Options) (string, string, string, string) {

	test_structure.RunTestStage(t, "init_dependencies", func() {
		logger.Log(t, "terraform init dependencies...")
		terraform.Init(t, terraform_dependencies_options)
	})

	test_structure.RunTestStage(t, "apply_dependencies", func() {
		logger.Log(t, "terraform apply dependencies ...")
		terraform.Apply(t, terraform_dependencies_options)
	})

	// create instance
	vcn_ocid := terraform.Output(t, terraform_dependencies_options, "vcn_ocid")
	nginx_subnet_ocids := terraform.Output(t, terraform_dependencies_options, "nginx_subnet_ocids")
	bastion_subnet_ocid := terraform.Output(t, terraform_dependencies_options, "bastion_subnet_ocid")
	lb_subnet_ocid := terraform.Output(t, terraform_dependencies_options, "lb_subnet_ocid")

	return vcn_ocid, nginx_subnet_ocids, bastion_subnet_ocid, lb_subnet_ocid
}

func TestGetInstanceParameter(ctx context.Context, c core.ComputeClient, instance_id string, parameter string) string {
	request := core.GetInstanceRequest{
		InstanceId: common.String(instance_id),
	}
	r, err := c.GetInstance(ctx, request)
	if err != nil {
		fmt.Println(err)
	}

	switch parameter {
	case "ImageId":
		fmt.Println("Image ID: ", *r.Instance.ImageId)
		return *r.Instance.ImageId
	case "Shape":
		fmt.Println("Shape: ", *r.Instance.Shape)
		return *r.Instance.Shape
	case "DisplayName":
		fmt.Println("DisplayName: ", *r.Instance.DisplayName)
		return *r.Instance.DisplayName
	case "CompartmentId":
		fmt.Println("CompartmentId: ", *r.Instance.CompartmentId)
		return *r.Instance.CompartmentId
	}
	return "Select the correct name of the instance parameter"
}

func FindInstanceInInstancesListRestAPI(t *testing.T, instance_name string, verify_created bool, compartment_id string) {
	ctx, c := CreateComputeClient()
	instanciesList := []string{}
	for _, element := range TestListInstancies(ctx, c, compartment_id) {
		if element.LifecycleState == "RUNNING" {
			instanciesList = append(instanciesList, *element.DisplayName)
		}
	}
	if verify_created == true {
		fmt.Printf("Verify instance with name '%s' is created ...\n", instance_name)
		assert.Contains(t, instanciesList, instance_name)
	} else {
		fmt.Printf("Verify instance with name '%s' is not created ...\n", instance_name)
		assert.NotContains(t, instanciesList, instance_name)
	}
}
