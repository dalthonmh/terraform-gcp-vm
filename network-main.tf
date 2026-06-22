####################
## Network - Main ##
####################

locals {
  vpc_name    = "${lower(var.company)}-${lower(var.app_name)}-${var.environment}-vpc"
  subnet_name = "${lower(var.company)}-${lower(var.app_name)}-${var.environment}-subnet"
}

# Create custom VPC (no default subnets)
resource "google_compute_network" "vpc" {
  name                    = local.vpc_name
  description             = "Custom VPC for ${var.app_name} ${var.environment}"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"

  depends_on = [google_project_service.required["compute.googleapis.com"]]
}

# Public subnet (single region for demo)
resource "google_compute_subnetwork" "network_subnet" {
  name          = local.subnet_name
  description   = "Public subnet for VM"
  ip_cidr_range = var.network-subnet-cidr
  network       = google_compute_network.vpc.name
  region        = var.gcp_region
}
