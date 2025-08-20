# variables.tf - Variables avec Single AZ par défaut

variable "aws_region" {
  description = "AWS region for ROSA cluster"
  type        = string
  default     = "us-east-1"
}

variable "availability_zone" {
  description = "Specific availability zone for single AZ deployment"
  type        = string
  default     = "us-east-1a"
  validation {
    condition     = length(var.availability_zone) > 0
    error_message = "Availability zone must be specified for single AZ deployment."
  }
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
  default     = "openshift-testing"
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
  description = "Number of compute nodes (must be even for multi-AZ, any number for single-AZ)"
  type        = number
  default     = 2
  validation {
    condition     = var.compute_replicas >= 2
    error_message = "Compute replicas must be at least 2."
  }
}

# Nouvelle variable pour contrôler Single AZ vs Multi-AZ
variable "single_az_deployment" {
  description = "Deploy cluster in single availability zone instead of multi-AZ"
  type        = bool
  default     = true  # Par défaut Single AZ
}

variable "multi_az" {
  description = "Deploy across multiple availability zones (deprecated - use single_az_deployment)"
  type        = bool
  default     = false  # Par défaut Single AZ
}

# Configuration réseau adaptée pour Single AZ
variable "machine_cidr" {
  description = "CIDR block for machines (Single AZ requires smaller CIDR)"
  type        = string
  default     = "10.0.0.0/16"  # Plus petit pour Single AZ
}

variable "service_cidr" {
  description = "CIDR block for services"
  type        = string
  default     = "172.30.0.0/16"
}

variable "pod_cidr" {
  description = "CIDR block for pods"
  type        = string
  default     = "10.128.0.0/14"
}

variable "host_prefix" {
  description = "Host prefix for pod CIDR"
  type        = number
  default     = 23
}
