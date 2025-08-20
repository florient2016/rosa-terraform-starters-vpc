## rosa-sts-resources.tf - Using RHCS Provider Resources
#
## 1. OCM Role
#resource "rhcs_rosa_ocm_role" "ocm_role" {
#  ocm_role_prefix = var.prefix
#  aws_account_id  = local.account_id
#  
#  tags = local.common_tags
#}
#
## 2. User Role  
#resource "rhcs_rosa_user_role" "user_role" {
#  user_role_prefix = var.prefix
#  aws_account_id   = local.account_id
#  
#  tags = local.common_tags
#}
#
## 3. Account Roles
#resource "rhcs_rosa_account_roles" "account_roles" {
#  account_role_prefix = var.prefix
#  aws_account_id      = local.account_id
#  openshift_version   = var.openshift_version
#  
#  tags = local.common_tags
#}
#
## 4. OIDC Configuration
#resource "rhcs_rosa_oidc_config" "oidc_config" {
#  managed = true
#  
#  tags = local.common_tags
#}
#
## 5. Operator Roles (requires OIDC config)
#resource "rhcs_rosa_operator_roles" "operator_roles" {
#  operator_role_prefix = "${var.prefix}-operator"
#  account_role_prefix  = var.prefix
#  aws_account_id       = local.account_id
#  openshift_version    = var.openshift_version
#  oidc_config_id       = rhcs_rosa_oidc_config.oidc_config.id
#  
#  tags = local.common_tags
#  
#  depends_on = [
#    rhcs_rosa_account_roles.account_roles,
#    rhcs_rosa_oidc_config.oidc_config
#  ]
#}
