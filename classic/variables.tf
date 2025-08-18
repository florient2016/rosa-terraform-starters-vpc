variable "cluster_name" {
  type        = string
  description = "Unique ROSA Classic cluster name (DNS-friendly; 1–15 chars recommended)."
}

variable "openshift_version" {
  type        = string
  description = "OpenShift version stream; use 'stable' to track the latest stable ROSA Classic."
  default     = "stable"
}

variable "region" {
  type        = string
  description = "AWS region for the cluster and IAM resources."
  default     = "eu-central-1"
}

variable "multi_az" {
  type        = bool
  description = "Deploy the cluster across multiple AZs."
  default     = true
}

variable "public" {
  type        = bool
  description = "Create a public (Internet-accessible) cluster API and ingress."
  default     = true
}

variable "replicas" {
  type        = number
  description = "Number of worker node replicas (for multi-AZ, typically a multiple of 3)."
  default     = 3
}

variable "machine_type" {
  type        = string
  description = "EC2 instance type for worker nodes."
  default     = "m5.xlarge"
}
