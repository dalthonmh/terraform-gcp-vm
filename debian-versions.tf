####################################
## Debian Image (latest in family) ##
####################################

# This fetches the latest Debian 13 image automatically.
# Much more reliable than hardcoding a family string.
data "google_compute_image" "debian_13" {
  family  = "debian-13"
  project = "debian-cloud"

  # Ensure the Compute API is enabled before trying to read images
  depends_on = [google_project_service.required["compute.googleapis.com"]]
}

# Kept for backwards compatibility / override if someone really wants a custom image
variable "debian_13_sku" {
  type        = string
  description = "(Optional) Override with a specific image self_link or family reference. Leave empty to use latest debian-13."
  default     = ""
}
