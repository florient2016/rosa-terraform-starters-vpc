# outputs.tf
output "aws_account_id" {
  description = "AWS Account ID where resources are created"
  value       = local.account_id
}

output "rosa_ocm_role_arn" {
  description = "ARN of the OCM role"
  value       = aws_iam_role.ocm_role.arn
}

output "rosa_user_role_arn" {
  description = "ARN of the User role"
  value       = aws_iam_role.user_role.arn
}

output "rosa_installer_role_arn" {
  description = "ARN of the Installer role"
  value       = aws_iam_role.account_roles["installer"].arn
}

output "rosa_support_role_arn" {
  description = "ARN of the Support role"
  value       = aws_iam_role.account_roles["support"].arn
}

output "rosa_controlplane_role_arn" {
  description = "ARN of the Control Plane role"
  value       = aws_iam_role.account_roles["controlplane"].arn
}

output "rosa_worker_role_arn" {
  description = "ARN of the Worker role"
  value       = aws_iam_role.account_roles["worker"].arn
}

output "oidc_config_id" {
  description = "OIDC configuration ID"
  value       = rhcs_rosa_oidc_config.oidc_config.id
}

output "oidc_provider_arn" {
  description = "ARN of the AWS OIDC provider"
  value       = aws_iam_openid_connect_provider.rosa_oidc.arn
}

output "operator_role_arns" {
  description = "Map of operator role ARNs"
  value = {
    for k, role in aws_iam_role.operator_roles : k => role.arn
  }
}

output "all_role_arns" {
  description = "All ROSA STS role ARNs"
  value = {
    ocm_role          = aws_iam_role.ocm_role.arn
    user_role         = aws_iam_role.user_role.arn
    installer_role    = aws_iam_role.account_roles["installer"].arn
    support_role      = aws_iam_role.account_roles["support"].arn
    controlplane_role = aws_iam_role.account_roles["controlplane"].arn
    worker_role       = aws_iam_role.account_roles["worker"].arn
  }
}

output "rosa_create_cluster_command" {
  description = "ROSA CLI command to create cluster"
  value = <<-EOT
    rosa create cluster \
      --cluster-name "${var.prefix}-cluster" \
      --sts \
      --role-arn "${aws_iam_role.account_roles["installer"].arn}" \
      --support-role-arn "${aws_iam_role.account_roles["support"].arn}" \
      --controlplane-iam-role "${aws_iam_role.account_roles["controlplane"].arn}" \
      --worker-iam-role "${aws_iam_role.account_roles["worker"].arn}" \
      --oidc-config-id "${rhcs_rosa_oidc_config.oidc_config.id}" \
      --region "${var.aws_region}" \
      --version "${var.openshift_version}"
  EOT
}

# Summary output
output "summary" {
  description = "Summary of created resources"
  value = {
    prefix            = var.prefix
    region           = var.aws_region
    account_id       = local.account_id
    roles_created    = length(aws_iam_role.account_roles) + 2  # +2 for OCM and User roles
    oidc_config_id   = rhcs_rosa_oidc_config.oidc_config.id
    operator_roles   = length(aws_iam_role.operator_roles)
  }
}
