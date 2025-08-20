# outputs.tf - Updated outputs with OpenShift version

# Extract major.minor version for consistent naming
locals {
  openshift_major_minor = join(".", slice(split(".", var.openshift_version), 0, 2))
}

output "account_role_arns" {
  description = "ARNs of all account roles"
  value = {
    installer     = aws_iam_role.account_roles["installer"].arn
    support       = aws_iam_role.account_roles["support"].arn
    controlplane  = aws_iam_role.account_roles["controlplane"].arn
    worker        = aws_iam_role.account_roles["worker"].arn
  }
}

output "instance_profile_arns" {
  description = "ARNs of instance profiles"
  value = {
    controlplane = aws_iam_instance_profile.controlplane_instance_profile.arn
    worker       = aws_iam_instance_profile.worker_instance_profile.arn
  }
}

output "external_id" {
  description = "External ID for Red Hat role assumption"
  value     = random_uuid.external_id.result
  sensitive = true
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
