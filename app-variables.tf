#############################
## Application - Variables ##
#############################

variable "company" {
  type        = string
  description = "Company or organization prefix used in resource names"
}

variable "app_name" {
  type        = string
  description = "Application name used in resource naming"
}

variable "app_domain" {
  type        = string
  description = "Domain for VM hostname (can be fake for internal use)"
  default     = "local"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, test, prod, etc.)"
  default     = "dev"
}

