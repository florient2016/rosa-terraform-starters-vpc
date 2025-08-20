# variables.tf
variable "prefix" {
  type        = string
  description = "Prefix for ROSA STS role names (equivalent to $SUFFIX in CLI)"
  default     = "rosa-sts"
  
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

variable "aws_account_id" {
  type        = string
  description = "AWS account ID (optional, will auto-detect if not provided)"
  default     = ""
}

variable "openshift_version" {
  type        = string
  description = "OpenShift version for ROSA cluster"
  default     = "4.14"
}

variable "operator_role_prefix" {
  type        = string
  description = "Prefix for operator roles"
  default     = ""
}

variable "oidc_config_id" {
  type        = string
  description = "OIDC config ID (optional, will be auto-generated if not provided)"
  default     = ""
}
