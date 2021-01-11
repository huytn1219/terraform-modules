# Terraform Module

This repo contains [Terraform](https://www.terraform.io/?_ga=2.87211550.783776628.1583200684-1012764625.1583200684) modules for building various resources on [Google Cloud Platform (GCP)](https://cloud.google.com/)

## Quickstart

This repo has the following folder structure:

* [root]: The root folder contains the main implementation code for the modules, broken down into multiple standalone submodules.
* [test]: Automated tests for the submodules and examples. TODO

## What's a Module?

A Module is a canonical, reusable, best-practices definition for how to run a single piece of infrastructure, such as a database or server cluster. Each module is written using a combination of [Terraform resources](https://www.terraform.io/docs/providers/index.html) and bash scripts and include automated tests, documentation, and examples.

## How to use Modules?

Modules are called from within other modules using `module` blocks:

```
module "servers" {
    source = "./app-cluster"
    #Note: If modules are located on differrent repo or registries, you can call that repo by using address scheme:
    # source = "git@github.com:team/example.git"
    servers = 5
}
```

## How to run a Module?

1. Install [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) v0.12.0 or later.
2. Open `variables.tf`, and fill any required variables that don't have a default. You can also use environment variables to define your Terraform variables. Please see [Terraform CLI](https://www.terraform.io/docs/commands/environment-variables.html)for more information.
3. Run `terraform init`.
4. Run `terraform plan`.
5. If the plan looks good, run `terraform apply` to apply your change.
6. To destroy what you have applied, run `terraform destroy`# terraform-modules
