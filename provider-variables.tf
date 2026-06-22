##############################
## GCP Provider - Variables ##
##############################

variable "gcp_auth_file" {
  type        = string
  description = "Path to GCP service account JSON key file. Leave empty to use Application Default Credentials (ADC) or GOOGLE_APPLICATION_CREDENTIALS environment variable."
  default     = ""
}

variable "gcp_project" {
  type        = string
  description = "GCP project ID (NOT the numeric project number, NOT the display name). Example: my-project-123456"
}

variable "gcp_region" {
  type        = string
  description = "GCP region (e.g. europe-west4, us-central1)"
}

variable "gcp_zone" {
  type        = string
  description = "GCP zone inside the region (e.g. europe-west4-b)"
}
