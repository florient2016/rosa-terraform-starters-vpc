# data.tf
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  account_id = var.aws_account_id != "" ? var.aws_account_id : data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  
  common_tags = {
    Environment = "rosa-sts"
    ManagedBy   = "terraform"
    Purpose     = "rosa-cluster"
    Prefix      = var.prefix
  }
}
