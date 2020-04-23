# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# This module uses latest version of terraform which is 0.12.20.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
    required_version = ">= 0.12.7"
}

resource "google_compute_network" "vpc" {
    name        = "${var.name_prefix}-network"
    project     = var.project

    # Always define custom subnetworks - one subnetwork per region isn't useful.
    auto_create_subnetworks = "false"

    # A global routing mode can have an unexpected impact on load balacners; always use a regional mode
    routing_mode = "REGIONAL"
}
resource "google_compute_router" "vpc_router" {
    name = "${var.name_prefix}-router"

    project = var.project
    region  = var.region
    network = google_compute_network.vpc.self_link
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Public Subnetwork Config
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

resource "google_compute_subnetwork" "vpc_subnetwork_public" {
    name        = "${var.name_prefix}-subnetwork-public"

    project     = var.project
    region      = var.region
    network     = google_compute_network.vpc.self_link

    private_ip_google_access = true
    ip_cidr_range            = cidrsubnet(var.cidr_block, var.cidr_subnetwork_width_delta, 0)

    secondary_ip_range {
        range_name = "public-services"
        ip_cidr_range = cidrsubnet(
            var.secondary_cidr_block,
            var.secondary_cidr_subnetwork_width_delta,
            0
        )
    }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Cloud NAT for external access
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

resource "google_compute_router_nat" "vpc_nat" {
    name = "${var.name_prefix}-nat"

    project = var.project
    region  = var.region
    router  = google_compute_router.vpc_router.name
    
    nat_ip_allocate_option = "AUTO_ONLY"

    # "Manually" define the subnetworks for which the NAT is used, so that we can exclude the public subnetwork
    source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

    subnetwork {
        name                    = google_compute_subnetwork.vpc_subnetwork_public.self_link
        source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Private Subnetwork Config
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

resource "google_compute_subnetwork" "vpc_subnetwork_private" {
    name = "${var.name_prefix}-subnetwork-private"

    project = var.project
    region  = var.region
    network = google_compute_network.vpc.self_link

    private_ip_google_access = true
    ip_cidr_range = cidrsubnet(
        var.cidr_block,
        var.cidr_subnetwork_width_delta,
        1 * (1 + var.cidr_subnetwork_spacing)
    )

    secondary_ip_range {
        range_name = "private-services"
        ip_cidr_range = cidrsubnet(
            var.secondary_cidr_block,
            var.secondary_cidr_subnetwork_width_delta,
            1 * (1 + var.secondary_cidr_subnetwork_spacing)
        )
    }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Shared VPC
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "google_compute_shared_vpc_host_project" "shared_vpc_host" {
    count    = var.shared_vpc_host ? 1 : 0
    project  = var.project
    depends_on = [google_compute_network.vpc]
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Attach Firewall Rules to allow inbound traffic to tagged instances
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
module "network_firewall" {
    source = "../sw-gcp-network-firewall"
     
    name_prefix = var.name_prefix

    project                               = var.project
    network                               = google_compute_network.vpc.self_link
    allowed_public_restricted_subnetworks = var.allowed_public_restricted_subnetworks

    public_subnetwork   = google_compute_subnetwork.vpc_subnetwork_public.self_link
    private_subnetwork  = google_compute_subnetwork.vpc_subnetwork_private.self_link
}

    






