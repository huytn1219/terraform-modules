# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These parameters must be supplied when consuming this module.
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
   description = "Name of the cluster" 
   type        = string
}

variable "project" {
    description = "The project ID to host the cluster in"
    type        = string
}

variable "location" {
    description = "The location (region or zone) to host the cluster in"
    type        = string
}

variable "network" {
    description = "A reference (self link) to the VPC network to host the cluster in"
    type        = string
}

variable "subnetwork" {
    description = "A reference to the subnetwork to host the clister in"
    type        = string
}

variable "cluster_secondary_range_name" {
    description = "The name of the secondary range within the subnetwork for the cluster to use"
    type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# Generally, these values won't need to be changed.
# ---------------------------------------------------------------------------------------------------------------------
variable "description" {
    description = "The description of the cluster"
    type        = string
    default     = ""
}

variable "kubernetes_version" {
    description = "The Kubernetes version of the masters. If set to 'latest' it will pull the latest version in the selected region"
    type        = string
    default     = "latest"
}

variable "logging_service" {
    description = "The logging service that the cluster should write logs to. Available options include logging.googleapis.com/kubernetes, logging.googleapis.com/legacy, and none"
    type        = string
    default     = "logging.googleapis.com/kubernetes"
}

variable "monitoring_service" {
    description = "The monitoring service that the cluster should write metrics to. Automatically send metrics from pods in the cluster to the Stackdriver Monitoring API. VM metrics will be collected by Google Compute Engine regardless of this setting. Available options include monitoring.googleapis.com/kubernetes, monitoring.googleapis.com (legacy), and none"
    type        = string
    default     = "monitoring.googleapis.com/kubernetes"
}

variable "network_project" {
    description = "The project ID of the shared VPC's host (for shared VPC support)"
    type        = string
    default     = ""
}

variable "disable_public_endpoint" {
    description = "Control whether the master's internal IP address is used as the cluster endpoint. If set to 'true', the master can only be accessed from internal IP addresses."
    type        = bool
    default     = false
}

variable "enable_private_nodes" {
    description = "Control whether nodes have internal IP addresses only. If enabled, all nodes are given only RFC 1918 private addresses and communicate with the master via private networking."
    type        = bool
    default     = false
}

variable "master_ipv4_cidr_block" {
    description = "The IP range in CIDR notation to use for the hosted master network. This range will be used for assigning internal IP addresses to the master or set of masters, as well as the ILB VIP. This range must not overlap with any other ranges in use within the cluster's network."
    type        = string
    default     = ""
}

variable "http_load_balancing" {
    description = "Whether to enable the http (L7) load balancing addon"
    type        = bool
    default     = true
}

variable "horizontal_pod_autoscaling" {
    description = "Whether to enable the horizontal pod autoscaling addon"
    type        = bool
    default     = true
}

variable "enable_network_policy" {
    description = "Whether to enable Kubernetes NetworkPolicy on the master, which is required to be enabled to be used on Nodes"
    type        = bool
    default     = true
}

variable "basic_auth_username" {
    description = "The username used for basic auth - set both this and `basic_auth_password` to empty to disable basic auth."
    type        = string
    default     = ""
}

variable "basic_auth_password" {
    description = "The password used for basic auth - set both this and basic_auth_username to empty to disable basic auth."
    type        = string
    default     = ""
}

variable "master_authorized_networks_config" {
    description = <<EOF
    The desired configuration options for master authorized networks. Omit the nested cidr_blocks attribute to disallow external access (except the cluster node IPs, which GKE automatically whitelists)
    ### example format ###
    master_authorized_networks_config = [{
    cidr_blocks = [{
      cidr_block   = "10.0.0.0/8"
      display_name = "example_network"
    }],
  }]
  
EOF
    type        = list(any)
    default     = []
}

variable "maintenance_start_time" {
  description = "Time window specified for daily maintenance operations in RFC3339 format"
  type        = string
  default     = "05:00"
}

# See https://cloud.google.com/kubernetes-engine/docs/how-to/role-based-access-control#google-groups-for-gke
variable "gsuite_domain_name" {
  description = "The domain name for use with Google security groups in Kubernetes RBAC. If a value is provided, the cluster will be initialized with security group `gke-security-groups@[yourdomain.com]`."
  type        = string
  default     = ""
}







