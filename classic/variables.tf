variable "cluster_name" {
  type        = string
  description = "Name of the ROSA HCP cluster"
  
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,14}[a-z0-9]$", var.cluster_name))
    error_message = "Cluster name must start with a letter, contain only lowercase letters, numbers, and hyphens, and be 2-15 characters long."
  }
}

variable "openshift_version" {
  type        = string
  description = "OpenShift version to use for the cluster"
  default     = "4.14.15"
}

variable "region" {
  type        = string
  description = "AWS region where the cluster will be created"
  default     = "us-west-2"
}

variable "multi_az" {
  type        = bool
  description = "Deploy cluster across multiple availability zones"
  default     = false
}

variable "public" {
  type        = bool
  description = "Create a public cluster (API and ingress endpoints accessible from the internet)"
  default     = true
}

variable "replicas" {
  type        = number
  description = "Number of worker nodes per availability zone"
  default     = 2
  
  validation {
    condition     = var.replicas >= 2
    error_message = "ROSA HCP clusters require at least 2 worker nodes."
  }
}

variable "machine_type" {
  type        = string
  description = "Instance type for worker nodes"
  default     = "m5.xlarge"
}

variable "create_vpc" {
  type        = bool
  description = "Create a new VPC for the cluster"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "AWS resource tags to apply to all resources"
  default = {
    Environment = "dev"
    Project     = "rosa-hcp"
    ManagedBy   = "terraform"
  }
}
