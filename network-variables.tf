#########################
## Network - Variables ##
#########################

variable "network-subnet-cidr" {
  type        = string
  description = "CIDR range for the subnet (e.g. 10.10.10.0/24)"
  default     = "10.10.10.0/24"
}