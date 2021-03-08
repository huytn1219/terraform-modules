# VPC Network Module

This repo contains Terraform files that create a [Virtual Private Cloud (VPC)](https://cloud.google.com/vpc/docs/using-vpc) on [Google Cloud Platform (GCP)](https://cloud.google.com/gcp/?utm_source=google&utm_medium=cpc&utm_campaign=na-US-all-en-dr-bkws-all-all-trial-b-dr-1008076&utm_content=text-ad-none-any-DEV_c-CRE_115268617687-ADGP_Hybrid+%7C+AW+SEM+%7C+BKWS+%7C+US+%7C+en+%7C+BMM+~+Clouds+Google-KWID_43700010161690057-kwd-64595508764&utm_term=KW_%2Bclouds%20%2Bgoogle-ST_%2Bclouds+%2Bgoogle&gclid=EAIaIQobChMI3J_EqoCA6AIVUNbACh0AswkREAAYASAAEgLAl_D_BwE) following best practices.

This module supports creating:
* A VPC Network.
* VPC public subnets.
* A VPC NAT to allow K8S pods access public internet.
* VPC Private subnets.
* A Network Firewall.
* Optionally enabling the network as a Shared VPC host.

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
| project | The project ID for the network. | string | No| Yes| dev|
| region | The region for subnetworks in the network. | string | No| Yes| us-central1 |
| name_prefix | A name prefix used in resource names to ensure uniqueness across a project.| string | No | Yes| test-network|
| cidr_block | The IP address range of the VPC in CIDR notation. A prefix of /16 is recommended. Do not use a prefix higher than /27.| string | 10.5.0.0/16| No | N/A|
| cidr_subnetwork_width_delta| The difference between your network and subnetwork netmask; an /16 network and a /20 subnetwork would be 4.| number | 4| No| N/A|
| cidr_subnetwork_spacing| How many subnetwork-mask sized spaces to leave between each subnetwork type.| number | 0 | No | N/A|
| secondary_cidr_block|The IP address range of the VPC's secondary address range in CIDR notation. A prefix of /16 is recommended. Do not use a prefix higher than /27.| string |10.6.0.0/16 | No| N/A|
|secondary_cidr_subnetwork_width_delta| The difference between your network and subnetwork's secondary range netmask; an /16 network and a /20 subnetwork would be 4.| number | 4| No| N/A|
|secondary_cidr_subnetwork_spacing| How many subnetwork-mask sized spaces to leave between each subnetwork type's secondary ranges.| number| 0 | No|N/A|
|enable_flow_logging|Whether to enable VPC Flow Logs being sent to Stackdriver (https://cloud.google.com/vpc/docs/using-flow-logs)| bool| true|No|N/A|
|allowed_public_restricted_subnetworks|The public networks that is allowed access to the public_restricted subnetwork of the network.| list(string)| [] | No | N/A|

## Outputs
| Name | Description |
| ---- | ----------- |
| network | A reference (self_link) to the VPC network. |
| public_subnetwork | A reference (self_link) to the public subnetwork.|
| public_subnetwork_name| Name of the public subnetwork.|
|public_subnetwork_cidr_block| IP Address range of public subnet.|
| public_subnetwork_gateway| Gateway IP address of public subnet.|
| public_subnetwork_secondary_cidr_block| IP Address range of secondary public subnet. |
| public_subnetwork_secondary_range_name| Name of public secondary address range.|
| private_subnetwork | A reference (self_link) to the private subnetwork.|
|private_subnetwork_name|Name of the private subnet.|
|private_subnetwork_cidr_block|IP Address range of private subnet.|
|private_subnetwork_gateway|Gateway IP address of public subnet.|
|private_subnetwork_secondary_cidr_block| IP Address range of secondary private subnet.|
|private_subnetwork_secondary_range_name| IP Address range of secondary private subnet|
|private_subnetwork_secondary_range_name|Name of private secondary address range|

## How to call this Module?
Modules are called from within other modules using module blocks:

```
module "sw-gcp-network" {
    source = "./app-cluster"
    #Note: If modules are located on differrent repo or registries, you can call that repo by using address scheme:
    # source = "git@github.com:team/example.git//subfolder"
    servers = 5
}
```

## License & References:
Please see [LICENSE](https://github.com/gruntwork-io/terraform-google-gke/blob/master/LICENSE) for how the code in this repo is licensed.
Please also see [Grunkwork.io](https://github.com/gruntwork-io/terraform-google-gke) for how this module is referenced to.


