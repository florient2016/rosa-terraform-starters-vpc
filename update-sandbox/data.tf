# data.tf - Updated to get ROSA account role policies
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

# Get available ROSA versions
data "rhcs_versions" "rosa_versions" {
  search = "enabled='t' and rosa_enabled='t' and channel_group='stable'"
}

# Get ROSA account role policies for the specific version
data "rhcs_rosa_operator_roles" "operator_roles" {
  operator_role_prefix = var.prefix
  account_role_prefix  = var.prefix
}

# Get the exact policies ROSA expects
data "rhcs_policies" "account_role_policies" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  
  # Red Hat's AWS account ID (extracted from policies)
  red_hat_aws_account = "710019948333"  # Official Red Hat AWS account
  
  common_tags = {
    Environment                  = "rosa-sts"
    ManagedBy                   = "terraform"
    Purpose                     = "rosa-cluster"
    Prefix                      = var.prefix
    "red-hat-managed"           = "true"
    "rosa.openshift.io/version" = var.openshift_version
  }
}
