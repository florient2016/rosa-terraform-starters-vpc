## rosa-sts-module.tf
#
## OIDC Configuration
#resource "rhcs_rosa_oidc_config" "oidc_config" {
#  count   = var.oidc_config_id == "" ? 1 : 0
#  managed = true
#}
#
#locals {
#  oidc_config_id = var.oidc_config_id != "" ? var.oidc_config_id : rhcs_rosa_oidc_config.oidc_config[0].id
#}
#
## Account Roles
#module "account_iam_resources" {
#  source  = "terraform-redhat/rosa-sts/rhcs"
#  version = ">= 0.0.14"
#
#  create_account_roles  = true
#  create_ocm_role      = true
#  create_user_role     = true
#  create_operator_roles = false
#
#  account_role_prefix = var.prefix
#  ocm_role_prefix     = var.prefix
#  user_role_prefix    = var.prefix
#  
#  openshift_version = local.openshift_version
#  aws_account_id    = local.account_id
#  
#  tags = local.common_tags
#}
#
## Operator Roles (created separately to avoid circular dependencies)
#module "operator_iam_resources" {
#  source  = "terraform-redhat/rosa-sts/rhcs"
#  version = ">= 0.0.14"
#
#  create_account_roles  = false
#  create_ocm_role      = false
#  create_user_role     = false
#  create_operator_roles = true
#
#  operator_role_prefix = var.operator_role_prefix != "" ? var.operator_role_prefix : var.prefix
#  account_role_prefix  = var.prefix
#  
#  openshift_version = local.openshift_version
#  aws_account_id    = local.account_id
#  oidc_config_id    = local.oidc_config_id
#  
#  tags = local.common_tags
#
#  depends_on = [module.account_iam_resources]
#}
