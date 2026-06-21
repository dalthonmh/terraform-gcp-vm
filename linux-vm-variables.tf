##############################
## GCP Linux VM - Variables ##
##############################

variable "linux_instance_type" {
  type        = string
  description = "VM machine type. Use e2-micro for free tier eligible (most regions)."
  default     = "e2-micro"
}
