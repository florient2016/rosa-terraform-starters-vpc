# outputs.tf
# Method 1: RHCS Resources Outputs
output "rosa_ocm_role_arn" {
  description = "ARN of the OCM role for ROSA cluster creation"
  value       = try(rhcs_rosa_ocm_role.ocm_role.arn, aws_iam_role.ocm_role.arn)
}

output "rosa_user_role_arn" {
  description = "ARN of the User role for ROSA cluster creation"
  value       = try(rhcs_rosa_user_role.user_role.arn, aws_iam_role.user_role.arn)
}

output "rosa_installer_role_arn" {
  description = "ARN of the Installer role"
  value       = try(rhcs_rosa_account_roles.account_roles.installer_role_arn, aws_iam_role.account_roles["installer"].arn)
}

output "rosa_support_role_arn" {
  description = "ARN of the Support role"
  value       = try(rhcs_rosa_account_roles.account_roles.support_role_arn, aws_iam_role.account_roles["support"].arn)
}

output "rosa_controlplane_role_arn" {
  description = "ARN of the Control Plane role"
  value       = try(rhcs_rosa_account_roles.account_roles.controlplane_role_arn, aws_iam_role.account_roles["controlplane"].arn)
}

output "rosa_worker_role_arn" {
  description = "ARN of the Worker role"  
  value       = try(rhcs_rosa_account_roles.account_roles.worker_role_arn, aws_iam_role.account_roles["worker"].arn)
}

output "oidc_config_id" {
  description = "ID of the OIDC configuration"
  value       = try(rhcs_rosa_oidc_config.oidc_config.id, aws_iam_openid_connect_provider.rosa_oidc.arn)
}

output "operator_role_arns" {
  description = "ARNs of all operator roles"
  value       = try(rhcs_rosa_operator_roles.operator_roles.operator_role_arns, {})
}

output "aws_account_id" {
  description = "AWS account ID where roles are created"
  value       = local.account_id
}

output "all_role_arns" {
  description = "Map of all ROSA STS role ARNs"
  value = {
    ocm_role          = try(rhcs_rosa_ocm_role.ocm_role.arn, aws_iam_role.ocm_role.arn)
    user_role         = try(rhcs_rosa_user_role.user_role.arn, aws_iam_role.user_role.arn)
    installer_role    = try(rhcs_rosa_account_roles.account_roles.installer_role_arn, aws_iam_role.account_roles["installer"].arn)
    support_role      = try(rhcs_rosa_account_roles.account_roles.support_role_arn, aws_iam_role.account_roles["support"].arn)
    controlplane_role = try(rhcs_rosa_account_roles.account_roles.controlplane_role_arn, aws_iam_role.account_roles["controlplane"].arn)
    worker_role       = try(rhcs_rosa_account_roles.account_roles.worker_role_arn, aws_iam_role.account_roles["worker"].arn)
  }
}

# CLI commands equivalent output
output "rosa_create_cluster_command" {
  description = "ROSA CLI command to create cluster using these roles"
  value = <<-EOT
    rosa create cluster \
      --cluster-name ${var.prefix}-cluster \
      --sts \
      --role-arn ${try(rhcs_rosa_account_roles.account_roles.installer_role_arn, aws_iam_role.account_roles["installer"].arn)} \
      --support-role-arn ${try(rhcs_rosa_account_roles.account_roles.support_role_arn, aws_iam_role.account_roles["support"].arn)} \
      --controlplane-iam-role ${try(rhcs_rosa_account_roles.account_roles.controlplane_role_arn, aws_iam_role.account_roles["controlplane"].arn)} \
      --worker-iam-role ${try(rhcs_rosa_account_roles.account_roles.worker_role_arn, aws_iam_role.account_roles["worker"].arn)} \
      --region ${var.aws_region} \
      --version ${var.openshift_version} \
      --compute-machine-type m5.xlarge \
      --replicas 3
  EOT
}
