# variables.tf - Additional variables for cluster creation

# Cluster configuration
variable "compute_machine_type" {
  description = "Machine type for compute nodes"
  type        = string
  default     = "m5.xlarge"
}

variable "compute_replicas" {
  description = "Number of compute nodes"
  type        = number
  default     = 3
}

variable "compute_min_replicas" {
  description = "Minimum number of compute nodes for autoscaling"
  type        = number
  default     = 3
}

variable "compute_max_replicas" {
  description = "Maximum number of compute nodes for autoscaling"
  type        = number
  default     = 6
}

variable "multi_az" {
  description = "Deploy cluster across multiple availability zones"
  type        = bool
  default     = true
}

variable "enable_autoscaling" {
  description = "Enable autoscaling for compute nodes"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "Subnet IDs for cluster deployment (optional)"
  type        = list(string)
  default     = null
}

variable "disable_workload_monitoring" {
  description = "Disable workload monitoring"
  type        = bool
  default     = false
}

variable "prevent_cluster_destroy" {
  description = "Prevent accidental cluster destruction"
  type        = bool
  default     = true
}

variable "additional_cluster_tags" {
  description = "Additional tags for the cluster"
  type        = map(string)
  default     = {}
}

variable "create_admin_user" {
  description = "Create cluster admin user"
  type        = bool
  default     = false
}

variable "create_htpasswd_idp" {
  description = "Create HTPasswd identity provider"
  type        = bool
  default     = false
}

variable "htpasswd_users" {
  description = "HTPasswd users for identity provider"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "additional_machine_pools" {
  description = "Additional machine pools configuration"
  type = map(object({
    machine_type        = string
    replicas           = number
    enable_autoscaling = bool
    min_replicas       = number
    max_replicas       = number
    labels             = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
    availability_zones = list(string)
  }))
  default = {}
}
