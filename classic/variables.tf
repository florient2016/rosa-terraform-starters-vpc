variable "cluster_name" {
  description = "Name of the ROSA cluster"
  type        = string
}

variable "openshift_version" {
  description = "Version of OpenShift to use (e.g., 4.16.13)"
  type        = string
}

variable "account_role_prefix" {
  description = "Prefix for account roles"
  type        = string
}

variable "operator_role_prefix" {
  description = "Prefix for operator roles"
  type        = string
}

variable "aws_region" {
  description = "AWS region for the cluster"
  type        = string
}

variable "availability_zones" {
  description = "List of AWS availability zones (e.g., ['us-east-1a']) - determines number of subnets"
  type        = list(string)
}

variable "private" {
  description = "Whether the cluster is private (true) or public (false)"
  type        = bool
  default     = false
}

variable "multi_az" {
  description = "Whether the cluster is multi-AZ"
  type        = bool
  default     = false
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]  # Adjust based on number of AZs
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]  # Adjust based on number of AZs
}

variable "ocm_role_name" {
  description = "Name of the OCM role"
  type        = string
  default     = "my-ocm-role"
}

variable "user_role_name" {
  description = "Name of the user role"
  type        = string
  default     = "my-user-role"
}
