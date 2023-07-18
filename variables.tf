# Variables for AWS infrastructure module

// TODO - use null defaults

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

# Required
variable "domain_name" {
  type        = string
  description = "Just a domain name"
}
