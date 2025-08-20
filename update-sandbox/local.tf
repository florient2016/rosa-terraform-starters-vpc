# locals.tf - Local values

locals {
  # Get current AWS account ID
  account_id = data.aws_caller_identity.current.account_id
  
  # Common tags
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    CreatedBy   = "Terraform"
    Prefix      = var.prefix
    Region      = var.aws_region
  }
  
  # Role ARNs that will be created by ROSA CLI
  installer_role_arn    = "arn:aws:iam::${local.account_id}:role/${var.prefix}-ManagedOpenShift-Installer-Role"
  support_role_arn      = "arn:aws:iam::${local.account_id}:role/${var.prefix}-ManagedOpenShift-Support-Role"
  controlplane_role_arn = "arn:aws:iam::${local.account_id}:role/${var.prefix}-ManagedOpenShift-ControlPlane-Role"
  worker_role_arn       = "arn:aws:iam::${local.account_id}:role/${var.prefix}-ManagedOpenShift-Worker-Role"
  
  # Cluster configuration
  cluster_name = "${var.prefix}-cluster"
  
  # Network CIDRs
  machine_cidr = "10.0.0.0/16"
  service_cidr = "172.30.0.0/16"
  pod_cidr     = "10.128.0.0/14"
  host_prefix  = 23
}

# Data sources
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_partition" "current" {}
