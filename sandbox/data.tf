# data.tf
data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

# Get available OpenShift versions
data "rhcs_versions" "rosa_versions" {
  search = "enabled='t' and rosa_enabled='t' and channel_group='stable'"
}

# Get ROSA policies from Red Hat (auto-discovers account IDs)
data "rhcs_rosa_operator_roles" "operator_roles" {
  operator_role_prefix = var.operator_role_prefix != "" ? var.operator_role_prefix : var.prefix
  account_role_prefix  = var.prefix
}

locals {
  # Auto-detect AWS account ID if not provided
  account_id = var.aws_account_id != "" ? var.aws_account_id : data.aws_caller_identity.current.account_id
  
  # AWS partition (aws, aws-gov, aws-cn)
  partition = data.aws_partition.current.partition
  
  # OpenShift version management
  openshift_version = var.openshift_version
  
  # Common tags
  common_tags = {
    Environment = "rosa-sts"
    ManagedBy   = "terraform"
    Purpose     = "rosa-cluster"
    Prefix      = var.prefix
  }
}
