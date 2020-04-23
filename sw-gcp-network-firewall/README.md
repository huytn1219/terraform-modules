# GCP Network Firewall Module

The Network Firewall module is used to configure a standard set of firewall rules for your network.

This module supports creating:

* A public subnetwork which allows ingress from anywhere and specific sources.
* A private subnetwork which allows ingress and ingress from `private` and `privat-persistence` instances from within network.

## Dependencies:

* [Terraform](https://www.terraform.io/downloads.html) v0.12.0 or later versions.

## Usage

1. Run `terraform init` to initialize a Terraform working directory.
2. Run `terraform plan -out tfplan.tf` to show an execution plan and also store the plan to tfplan.tf file for later use.
3. If the plan looks good, run `terraform apply tfplan.tf` to build or change infrastructure based on the execution plan file generated above. Note: Make sure to fill the required variable values when prompted.
4. To destroy what you have applied, run `terraform destroy`.

## Inputs

| Name          | Description       | Type      | Default       | Required | Example |   
| --------------| ----------------- | --------- | ------------- | -------- | ------- |
| network | A reference (self_link) to the VPC network to apply firewall rules to. | string | No| Yes | terraform-test|
| public_subnetwork| A reference (self_link) to the public subnetwork of the network.| string | No | Yes |terraform-test|
| allowed_public_restricted_subnetworks| The public networks that is allowed access to the public_restricted subnetwork of the network.| list(string)| [] | Yes| N/A|
|private_subnetwork| A reference (self_link) to the private subnetwork of the network. | string | No | Yes| N/A|
|project| The project to create the firewall rules in. Must match the network project.| string| No| Yes| N/A|
|name_prefix|A name prefix used in resource names to ensure uniqueness across a project.|string| No|Yes|N/A|

## Outputs

| Name | Descripton |
| ---- | ---------- |
|public| The string of the public tag.|
|public_restricted | The string of the public-restricted tag.|
|private|The string of the private tag.|
|private_persistence|The string of the private-persistence tag.|

## How to call this Module?

Modules are called from within other modules using module blocks:

```
module "network-firewall" {
    source = "./app-cluster"
    #Note: If modules are located on differrent repo or registries, you can call that repo by using address scheme:
    # source = "git@github.com:team/example.git"
    servers = 5
}
```

## License & Reference:

Please see [LICENSE](https://github.com/gruntwork-io/terraform-google-gke/blob/master/LICENSE) for how the code in this repo is licensed.

Please also see [Grunkwork.io](https://github.com/gruntwork-io/terraform-google-gke) for how this module is referenced to. 