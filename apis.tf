############################################
## Project APIs (Services) - Bootstrapping ##
############################################

# IMPORTANT:
# - The project MUST have billing enabled first.
# - Some foundational APIs are required for Terraform to even manage other APIs.
# - We enable the "bootstrap" APIs first (Cloud Resource Manager + Service Usage).
# - Then we enable the actual services we need.
#
# If you get errors about cloudresourcemanager or serviceusage, run:
#   gcloud services enable cloudresourcemanager.googleapis.com serviceusage.googleapis.com --project <ID>
#
# For service accounts, grant "roles/serviceusage.serviceUsageAdmin".
# For local dev, prefer: gcloud auth application-default login

locals {
  # Foundational APIs needed to manage other project services via Terraform
  bootstrap_apis = [
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
  ]

  # APIs our actual resources depend on
  required_apis = [
    "compute.googleapis.com",
    "iam.googleapis.com",
  ]
}

# Bootstrap APIs - these must be enabled before we can reliably manage other google_project_service resources
resource "google_project_service" "bootstrap" {
  for_each = toset(local.bootstrap_apis)

  project = var.gcp_project
  service = each.value

  # Never disable these during destroy - they are too fundamental
  disable_on_destroy         = false
  disable_dependent_services = false
}

# The APIs we actually use in this project
resource "google_project_service" "required" {
  for_each = toset(local.required_apis)

  project = var.gcp_project
  service = each.value

  # Do not disable the API on terraform destroy.
  # This prevents breaking other things in the project.
  disable_on_destroy         = false
  disable_dependent_services = false

  # Ensure bootstrap APIs are ready first
  depends_on = [google_project_service.bootstrap]
}

# === State migration (safe to keep) ===
# If you previously had the old single resources, migrate them to the new for_each addresses.
moved {
  from = google_project_service.compute_api
  to   = google_project_service.required["compute.googleapis.com"]
}

moved {
  from = google_project_service.iam_api
  to   = google_project_service.required["iam.googleapis.com"]
}
