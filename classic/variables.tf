variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the ROSA cluster"
  type        = string
}

variable "openshift_version" {
  description = "OpenShift version"
  type        = string
  default     = "4.14.6"
}

variable "multi_az" {
  description = "Deploy cluster across multiple availability zones"
  type        = bool
  default     = false
}

variable "create_vpc" {
  description = "Create a new VPC for the cluster"
  type        = bool
  default     = true
}

variable "aws_subnet_ids" {
  description = "List of AWS subnet IDs (required when create_vpc = false)"
  type        = list(string)
  default     = []
}

variable "machine_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "m5.xlarge"
}

variable "replicas" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "destroy_timeout" {
  description = "Timeout for cluster deletion"
  type        = number
  default     = 60
}

variable "upgrade_acknowledgements_for" {
  description = "Acknowledge upgrade for OpenShift version"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "rosa-hcp"
  }
}
