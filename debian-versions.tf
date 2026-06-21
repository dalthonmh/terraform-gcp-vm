#####################
## Debian Versions ##
#####################

variable "debian_13_sku" {
  type        = string
  description = "Debian 13 (Trixie) - Recommended"
  default     = "debian-cloud/debian-13"
}

variable "debian_12_sku" {
  type        = string
  description = "Debian 12 (Bookworm)"
  default     = "debian-cloud/debian-12"
}
