# outputs.tf - Clean version for HCP ROSA roles

# Account Role ARNs
output "installer_role_arn" {
  description = "ARN of the ROSA Installer role"
  value       = aws_iam_role.account_roles["installer"].arn
}

output "support_role_arn" {
  description = "ARN of the ROSA Support role"
  value       = aws_iam_role.account_roles["support"].arn
}

output "worker_role_arn" {
  description = "ARN of the ROSA Worker role"
  value       = aws_iam_role.account_roles["worker"].arn
}

# Instance Profile ARNs (only worker for HCP)
output "worker_instance_profile_arn" {
  description = "ARN of the ROSA Worker instance profile"
  value       = aws_iam_instance_profile.worker_instance_profile.arn
}

# Role Names (useful for ROSA cluster creation)
output "installer_role_name" {
  description = "Name of the ROSA Installer role"
  value       = aws_iam_role.account_roles["installer"].name
}

output "support_role_name" {
  description = "Name of the ROSA Support role"
  value       = aws_iam_role.account_roles["support"].name
}

output "worker_role_name" {
  description = "Name of the ROSA Worker role"
  value       = aws_iam_role.account_roles["worker"].name
}

output "worker_instance_profile_name" {
  description = "Name of the ROSA Worker instance profile"
  value       = aws_iam_instance_profile.worker_instance_profile.name
}

# Combined outputs for easy reference
output "account_roles" {
  description = "Map of all account role ARNs"
  value = {
    installer = aws_iam_role.account_roles["installer"].arn
    support   = aws_iam_role.account_roles["support"].arn
    worker    = aws_iam_role.account_roles["worker"].arn
  }
}

output "account_role_names" {
  description = "Map of all account role names"
  value = {
    installer = aws_iam_role.account_roles["installer"].name
    support   = aws_iam_role.account_roles["support"].name
    worker    = aws_iam_role.account_roles["worker"].name
  }
}

# Role prefix for reference
output "role_prefix" {
  description = "Prefix used for role names"
  value       = var.prefix
}

# OpenShift version for reference
output "openshift_version" {
  description = "OpenShift version these roles support"
  value       = var.openshift_version
}

# Account ID for reference
output "aws_account_id" {
  description = "AWS Account ID where roles are created"
  value       = data.aws_caller_identity.current.account_id
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
      --operator-roles-prefix "${var.prefix}" \
      --region "${var.aws_region}" \
      --version "${var.openshift_version}" \
      --compute-machine-type m5.xlarge \
      --replicas 3 \
      --external-id "${random_uuid.external_id.result}"
  EOT
}

output "validation_commands" {
  description = "Commands to validate the setup"
  value = <<-EOT
    # Check all roles exist
    aws iam get-role --role-name "${aws_iam_role.account_roles["installer"].name}"
    aws iam get-role --role-name "${aws_iam_role.account_roles["support"].name}"
    aws iam get-role --role-name "${aws_iam_role.account_roles["controlplane"].name}"
    aws iam get-role --role-name "${aws_iam_role.account_roles["worker"].name}"
    
    # Check instance profiles
    aws iam get-instance-profile --instance-profile-name "${aws_iam_instance_profile.controlplane_instance_profile.name}"
    aws iam get-instance-profile --instance-profile-name "${aws_iam_instance_profile.worker_instance_profile.name}"
    
    # Check OIDC provider
    aws iam get-openid-connect-provider --open-id-connect-provider-arn "${aws_iam_openid_connect_provider.rosa_oidc.arn}"
  EOT
}

output "role_names" {
  description = "Names of created roles for reference"
  value = {
    installer     = aws_iam_role.account_roles["installer"].name
    support       = aws_iam_role.account_roles["support"].name
    controlplane  = aws_iam_role.account_roles["controlplane"].name
    worker        = aws_iam_role.account_roles["worker"].name
  }
}

output "openshift_version_info" {
  description = "OpenShift version information"
  value = {
    full_version = var.openshift_version
    major_minor  = local.openshift_major_minor
  }
}
