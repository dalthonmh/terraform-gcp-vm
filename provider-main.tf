#########################
## GCP Provider - Main ##
#########################

terraform {
  required_version = "~> 1.6"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "google" {
  # If gcp_auth_file is provided, use explicit service account key.
  # Otherwise, rely on Application Default Credentials (ADC), gcloud auth, or GOOGLE_APPLICATION_CREDENTIALS env var.
  credentials = var.gcp_auth_file != "" ? file(var.gcp_auth_file) : null
  project     = var.gcp_project
  region      = var.gcp_region
  zone        = var.gcp_zone
}
