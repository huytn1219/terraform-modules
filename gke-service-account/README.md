# GKE Service Account Module

The GKE Service Account module is used to create GCP service account for use with a GKE cluster. It is based on the best practices referenced in this article: https://cloud.google.com/kubernetes-engine/docs/tutorials/authenticating-to-cloud-platform.

Thid module supports creating:
* A service account with the following roles - logging.logWriter, monitoring.metricWriter, monitoring.viewer, and stackdriver.resourceMetadata.writer.

## Dependencies:
* [Terraform](https://www.terraform.io/downloads.html) v0.12.0 or later versions.

## Usage
1. Run `terraform init` to initialize a Terraform working directory.
2. Run `terraform plan -out tfplan.tf` to show an execution plan and also store the plan to tfplan.tf file for later use.
3. If the plan looks good, run `terraform apply tfplan.tf` to build or change infrastructure based on the execution plan file generated above. Note: Make sure to fill the required variable values when prompted.
4. To destroy what you have applied, run `terraform destroy`.

## Inputs
| Name | Description | Type | Default | Required | Example |
| ---- | ----------- | ---- | ------- | -------- | ------- |
| project | The name of the GCP Project where all resources will be launched. | string| No | Yes |  |
| name | Name of the custom service account. This parameter is limited to a maximum of 28 characters. | string | No | Yes | terraform-test-gke |
| description |  The description of the custom service account. | string | "" | No | N/A |
| service_account_roles | Additional roles to be added to the service account. | list(string) | [] | No | N/A |  

## Outputs
| Name | Description |
| ---- | ----------- |
| email | The email address of the custom service account. |

## How to call this Module?
Modules are called from within other modules using module blocks:

```
module "gke-service-account" {
    source = "./app-cluster"
    #Note: If modules are located on differrent repo or registries, you can call that repo by using address scheme:
    # source = "git@github.com:team/example.git//subfolder"
    servers = 5
}
```

## License & References:

Please see [LICENSE](https://github.com/gruntwork-io/terraform-google-gke/blob/master/LICENSE) for how the code in this repo is licensed.

Please also see [Grunkwork.io](https://github.com/gruntwork-io/terraform-google-gke) for how this module is referenced to.




