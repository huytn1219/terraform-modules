# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY A GKE CLUSTER
# This module deploys a GKE cluster, a manged, production-ready environment for deploying containerized applications.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# This module uses latest version of terraform which is 0.12.20.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
terraform {
    required_version = ">= 0.12.20"
}

provider "google" {
    version = "~> 2.9.0"
    project = var.project
    region = "us-central1"
}

# ---------------------------------------------------------------------------------------------------------------------------
# Create the GKE Cluster
# We want to make a cluster with no node pools, and manage them all with the fine-grained google_container_node_pool resource
# ---------------------------------------------------------------------------------------------------------------------------

resource "google_container_cluster" "cluster" {
    provider    = google-beta

    name        = var.name
    description = var.description
    project     = var.project
    location    = var.location
    network     = var.network
    subnetwork  = var.subnetwork

    logging_service     = var.logging_service
    monitoring_service  = var.monitoring_service
    min_master_version  = local.kubernetes_version

    # We can't create a cluster with no node pool defined, but we want to only use
    # separately managed node pools. So we create the smallest possible default
    # node pool and immediately delete it.
    remove_default_node_pool = true

    initial_node_count = 1

    # ip_allocation_policy.use_ip_aliases defaults to true, since we define the block `ip_allocation_policy`
    ip_allocation_policy {
        // Chose the range, but let GCP pick the IPs within the range
        cluster_secondary_range_name  = var.cluster_secondary_range_name
        services_secondary_range_name = var.cluster_secondary_range_name
    }

    # We can optionally control access to the cluster
    # See https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters
    private_cluster_config {
        enable_private_endpoint = var.disable_public_endpoint
        enable_private_nodes    = var.enable_private_nodes
        master_ipv4_cidr_block  = var.master_ipv4_cidr_block
    }

    addons_config {
        http_load_balancing {
            disabled = ! var.http_load_balancing
        }

        horizontal_pod_autoscaling {
            disabled = ! var.horizontal_pod_autoscaling
        }

        network_policy_config {
            disabled = ! var.enable_network_policy
        }
    }

    network_policy {
        enabled = var.enable_network_policy

        # Tigera (Calico Felix) is the only provide
        provider = "CALICO"
    }

    master_auth {
        username = var.basic_auth_username
        password = var.basic_auth_password
    }

    dynamic "master_authorized_networks_config" {
        for_each = var.master_authorized_networks_config
        content {
            dynamic "cidr_blocks" {
                for_each = lookup(master_authorized_networks_config.value, "cidr_blocks", [])
                content {
                    cidr_block = cidr_block.value.cidr_block
                    display_name = lookup(cidr_block.value, "display_name", null)
                }
            }
        }
    }

    maintenance_policy {
        daily_maintenance_window {
            start_time = var.maintenance_start_time
        }
    }

    lifecycle {
        ignore_changes = [
            # Since we provide `remove_default_node_pool = true`, the `node_config` is only relevant for a valid construction of
            # the GKE cluster in the initial creation. As such, any changes to the `node_config` should be ignored.
            node_config,
        ]
    }

    # If var.gsuite_domain_name is non-empty, initialize the cluster with a G Suite security group
    dynamic "authenticator_groups_config" {
        for_each = [
            for x in [var.gsuite_domain_name] : x if var.gsuite_domain_name != null
        ]

        content {
            security_group = "gke-security-groups@${authenticator_groups_config.value}"
        }
    }
}


## ---------------------------------------------------------------------------------------------------------------------
## Prepare locals to keep the code cleaner
## ---------------------------------------------------------------------------------------------------------------------
locals {
    latest_version     = data.google_container_engine_versions.location.latest_master_version
    kubernetes_version = var.kubernetes_version != "latest" ? var.kubernetes_version : local.latest_version
    network_project    = var.network_project != "" ? var.network_project : var.project
}

## ---------------------------------------------------------------------------------------------------------------------
## Pull in data
## ---------------------------------------------------------------------------------------------------------------------
#// Get available master versions in our location to determine the latest version
data "google_container_engine_versions" "location" {
    location = var.location
    project  = var.project
}
