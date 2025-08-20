# variables.tf
variable "prefix" {
  type        = string
  description = "Prefix for ROSA STS role names"
  default     = "labs"
  
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.prefix))
    error_message = "Prefix must start with a letter and contain only alphanumeric characters and hyphens."
  }
}

variable "aws_region" {
  type        = string
  description = "AWS region where ROSA cluster will be deployed"
  default     = "us-east-1"
}

variable "openshift_version" {
  type        = string
  description = "OpenShift version for ROSA cluster"
  default     = "4.16.0"  # Updated to 4.16
  
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.openshift_version))
    error_message = "OpenShift version must be in format x.y.z (e.g., 4.16.0)."
  }
}

variable "path" {
  description = "IAM path for the roles"
  type        = string
  default     = "/"
}

variable "cluster_name" {
  description = "Name of the ROSA cluster"
  type        = string
  default     = "my-cluster"
}
