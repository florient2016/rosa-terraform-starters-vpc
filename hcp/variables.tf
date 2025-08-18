variable "aws_region" {
  description = "AWS region where the cluster will be created"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the ROSA HCP cluster"
  type        = string
  default     = "my-rosa-hcp-cluster"
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "my-cluster"
}

variable "openshift_version" {
  description = "OpenShift version"
  type        = string
  default     = "4.16.45"
}

variable "availability_zones_count" {
  description = "Number of availability zones"
  type        = number
  default     = 3
}

variable "create_account_roles" {
  description = "Create account roles (set to false if already exist)"
  type        = bool
  default     = true
}

variable "admin_username" {
  description = "Admin username for htpasswd IDP"
  type        = string
  default     = "admin"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "development"
    Project     = "rosa-hcp"
  }
}
