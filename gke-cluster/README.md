# GKE Public Cluster Module

The GKE Cluster module is used to administer the [cluster master](https://cloud.google.com/kubernetes-engine/docs/concepts/cluster-architecture) for a [Google Kubernetes Engine (GKE) Cluster](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-admin-overview).

The cluster master is the "control plane" of the cluster; for example, it runs the Kubernetes API used by `kubectl`.
Worker machines are configured by attaching [GKE node pools](https://cloud.google.com/kubernetes-engine/docs/concepts/node-pools) to the cluster module.

It supports creating:

* A public GKE cluster with 1 node. We want to make a cluster with no node pools, and manage them all with the fine-grained google_container_node_pool resource

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
| name			| Name of the cluster. |			string |		No | Yes	| terraform-test |
| project		| The project ID to host the cluster in. | string | No | Yes | shipwire-eng-core-dev |
| location		| The location (region or zone) to host the cluster in | string | No | Yes | us-central1 |
| network | A reference (self link) to the VPC network to host the cluster in. Note: You mush explicitly specify the network and subnetwork of your GKE cluster using the `network` and `subnetwork` fields; this module will not implicitly use the `default` network with an automatically generated network. | string | No | Yes | dev|
| subnetwork | A reference to the subnetwork to host the clister in. | string | No | Yes | dev-us-central1-pri |
| cluster_secondary_range_name | The name of the secondary range within the subnetwork for the cluster to use. Note: You must manually create a secondary range name in GCP web console. | string | No | Yes | terraform-secondary-range-test | 
| description | The description of the cluster. | string | "" | No | Dev cluster |
| kubernetes_version | The Kubernetes version of the masters. If set to 'latest' it will pull the latest version in the selected region. | string | "latest" | No | N/A |
| logging_service | The logging service that the cluster should write logs to. Available options include logging.googleapis.com/kubernetes, logging.googleapis.com/legacy, and none. | string | logging.googleapis.com/kubernetes. | No | N/A|
| monitoring_service | The monitoring service that the cluster should write metrics to. Automatically send metrics from pods in the cluster to the Stackdriver Monitoring API. VM metrics will be collected by Google Compute Engine regardless of this setting. Available options include monitoring.googleapis.com/kubernetes, monitoring.googleapis.com (legacy), and none. | string | monitoring.googleapis.com/kubernetes | No | N/A|
| network_project | The project ID of the shared VPC's host (for shared VPC support) | string | "" | No | N/A|
| disable_public_endpoint | Control whether the master's internal IP address is used as the cluster endpoint. If set to 'true', the master can only be accessed from internal IP addresses. | bool | false | No | N/A|
| enable_private_nodes | Control whether nodes have internal IP addresses only. If enabled, all nodes are given only RFC 1918 private addresses and communicate with the master via private networking. | bool | false | No | N/A|
| master_ipv4_cidr_block | The IP range in CIDR notation to use for the hosted master network. This range will be used for assigning internal IP addresses to the master or set of masters, as well as the ILB VIP. This range must not overlap with any other ranges in use within the cluster's network. | string | "" | No | N/A|
| http_load_balancing | Whether to enable the http (L7) load balancing addon. | bool | true | No | N/A|
| horizontal_pod_autoscaling | Whether to enable the horizontal pod autoscaling addon. | bool | true | No | N/A|
| enable_network_policy | Whether to enable Kubernetes NetworkPolicy on the master, which is required to be enabled to be used on Nodes. | bool | true | No | N/A |
| basic_auth_password | The username used for basic auth - set both this and `basic_auth_password` to empty to disable basic auth. | string | "" | No | N/A|
| master_authorized_networks_config | The desired configuration options for master authorized networks. Omit the nested cidr_blocks attribute to disallow external access (except the cluster node IPs, which GKE automatically whitelists). | list(any) | [] | No | N/A|
| maintenance_start_time | Time window specified for daily maintenance operations in RFC3339 format. | string | "05:00" | No | N/A|
| gsuite_domain_name | The domain name for use with Google security groups in Kubernetes RBAC. If a value is provided, the cluster will be initialized with security group `gke-security-groups@[yourdomain.com]`. | string | null | No | N/A|

## Outputs
| Name | Descripton |
| ---- | ---------- |
| name | Name of the cluster master. This output is used for interpolation with node pools, other modules. |
| master_version | The Kubernetes master version. |
| endpoint | The IP address of the cluster master. |
| client_certificate | Public certificate used by clients to authenticate to the cluster endpoint. |
| client_key | Private key used by clients to authenticate to the cluster endpoint. |
| cluster_ca_certificate | The public certificate that is the root of trust for the cluster.|
 


## How to call this Module?

Please refer to [root](https://bitbucket.org/shipwire/terraform-modules/src/master/) README.md for more information about using and running Terraform Modules

## License & Reference:
Please see [LICENSE](https://github.com/gruntwork-io/terraform-google-gke/blob/master/LICENSE) for how the code in this repo is licensed.

Please also see [Grunkwork.io](https://github.com/gruntwork-io/terraform-google-gke) for how this module is referenced to. 
