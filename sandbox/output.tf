# outputs.tf

# Module-based outputs
output "rosa_ocm_role_arn" {
  description = "ARN of the OCM role for ROSA cluster creation"
  value       = try(module.account_iam_resources.rosa_ocm_role_arn, aws_iam_role.ocm_role.arn)
}

output "rosa_user_role_arn" {
  description = "ARN of the User role for ROSA cluster creation"
  value       = try(module.account_iam_resources.rosa_user_role_arn, aws_iam_role.user_role.arn)
}

output "rosa_installer_role_arn" {
  description = "ARN of the Installer role"
  value       = try(
    module.account_iam_resources.rosa_installer_role_arn,
    aws_iam_role.account_roles["Installer-Role"].arn
  )
}

output "rosa_support_role_arn" {
  description = "ARN of the Support role"
  value       = try(
    module.account_iam_resources.rosa_support_role_arn,
    aws_iam_role.account_roles["Support-Role"].arn
  )
}

output "rosa_controlplane_role_arn" {
  description = "ARN of the Control Plane role"
  value       = try(
    module.account_iam_resources.rosa_controlplane_role_arn,
    aws_iam_role.account_roles["ControlPlane-Role"].arn
  )
}

output "rosa_worker_role_arn" {
  description = "ARN of the Worker role"
  value       = try(
    module.account_iam_resources.rosa_worker_role_arn,
    aws_iam_role.account_roles["Worker-Role"].arn
  )
}

# Operator roles (if created)
output "operator_role_arns" {
  description = "ARNs of all operator roles"
  value       = try(module.operator_iam_resources.operator_role_arns, {})
}

# OIDC Configuration
output "oidc_config_id" {
  description = "ID of the OIDC configuration"
  value       = local.oidc_config_id
}

output "oidc_config_issuer_url" {
  description = "Issuer URL of the OIDC configuration"
  value       = try(rhcs_rosa_oidc_config.oidc_config[0].oidc_endpoint_url, "")
}

# Account information
output "aws_account_id" {
  description = "AWS account ID where roles are created"
  value       = local.account_id
}

output "aws_partition" {
  description = "AWS partition"
  value       = local.partition
}

# All role ARNs for easy consumption
output "all_role_arns" {
  description = "Map of all ROSA STS role ARNs"
  value = {
    ocm_role        = try(module.account_iam_resources.rosa_ocm_role_arn, aws_iam_role.ocm_role.arn)
    user_role       = try(module.account_iam_resources.rosa_user_role_arn, aws_iam_role.user_role.arn)
    installer_role  = try(module.account_iam_resources.rosa_installer_role_arn, aws_iam_role.account_roles["Installer-Role"].arn)
    support_role    = try(module.account_iam_resources.rosa_support_role_arn, aws_iam_role.account_roles["Support-Role"].arn)
    controlplane_role = try(module.account_iam_resources.rosa_controlplane_role_arn, aws_iam_role.account_roles["ControlPlane-Role"].arn)
    worker_role     = try(module.account_iam_resources.rosa_worker_role_arn, aws_iam_role.account_roles["Worker-Role"].arn)
  }
}
