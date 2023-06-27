
# Required
variable "aws_access_key" {
  type        = string
  description = "AWS access key used to create infrastructure"
}

# Required
variable "aws_secret_key" {
  type        = string
  description = "AWS secret key used to create AWS infrastructure"
}

variable "aws_region" {
  type        = string
  description = "AWS region used for all resources"
  default     = "eu-west-1"
}

# Required
variable "suse_manager_subscription" {
  type        = string
  description = "SUSE Manager Subscription Key"
}

variable "prefix" {
  type        = string
  description = "Prefix added to names of all resources"
  default     = "suma-demo"
}