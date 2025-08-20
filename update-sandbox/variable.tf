# variables.tf - Variable definitions

variable "aws_region" {
  description = "AWS region for ROSA cluster"
  type        = string
  default     = "us-east-1"
}

variable "prefix" {
  description = "Prefix for all resources"
  type        = string
  default     = "labs"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.prefix))
    error_message = "Prefix must start with a letter and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "openshift_version" {
  description = "OpenShift version for ROSA cluster"
  type        = string
  default     = "4.18.22"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "lab"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "openshift-cluster"
}

variable "owner" {
  description = "Resource owner for tagging"
  type        = string
  default     = "platform-team"
}

variable "compute_machine_type" {
  description = "Machine type for compute nodes"
  type        = string
  default     = "m5.xlarge"
}

variable "compute_replicas" {
  description = "Number of compute nodes"
  type        = number
  default     = 3
  validation {
    condition     = var.compute_replicas >= 2
    error_message = "Compute replicas must be at least 2."
  }
}

variable "multi_az" {
  description = "Deploy cluster across multiple AZs"
  type        = bool
  default     = true
}
