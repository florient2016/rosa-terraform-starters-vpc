variable "cluster_name" {
  type        = string
  description = "Name of the ROSA cluster to create"
}

variable "openshift_version" {
  type        = string
  description = "Desired version of OpenShift for the cluster, for example '4.1.0'. If version is greater than the currently running version, an upgrade will be scheduled."
  default     = "4.16.0"
}

variable "region" {
  type        = string
  description = "AWS region where the cluster will be created"
  default     = "us-east-1"
}

variable "multi_az" {
  type        = bool
  description = "Multi AZ Cluster for High Availability"
  default     = false
}

variable "public" {
  type        = bool
  description = "Restrict cluster API endpoint and application routes to direct, private connectivity. This requires customers to have a pre-existing private connection through VPN, Direct Connect, Transit Gateway, etc."
  default     = true
}

variable "replicas" {
  description = "The amount of the machine created in this machine pool."
  type        = number
  default     = 2
}

variable "machine_type" {
  description = "Identifies the Instance type used by the default worker machine pool e.g. `m5.xlarge`. Use the `rhcs_machine_types` data source to find the possible values."
  type        = string
  default     = "m5.xlarge"
}

variable "create_vpc" {
  type        = bool
  description = "If true, a new VPC will be created for cluster"
  default     = true
}

variable "tags" {
  description = "List of AWS resource tags to apply."
  type        = map(string)
  default     = null
}