
# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# This module uses terraform 0.12 syntax and features that are available only since version 0.12.6, however
# we now depend on a bug fix released in 0.12.7.
# ----------------------------------------------------------------------------------------------------------------------
terraform {
    required_version = ">= 0.12.7"
}

# ----------------------------------------------------------------------------------------------------------------------
# Create Cluster Role Binding
# ----------------------------------------------------------------------------------------------------------------------

resource "kubernetes_cluster_role_binding" "devops" {
    provider = kubernetes
    
}



provider "kubernetes" {
    load_config_file = "false"

    host = var.endpoint

    client_certificate     = var.client_certificate
    client_key             = var.client_key
    cluster_ca_certificate = var.cluster_ca_certificate

}
