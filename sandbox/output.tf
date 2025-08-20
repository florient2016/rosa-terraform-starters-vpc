# outputs.tf - Updated outputs with OIDC info

output "oidc_config_id" {
  description = "OIDC configuration ID"
  value       = rhcs_rosa_oidc_config.oidc_config.id
}

output "oidc_endpoint_url" {
  description = "OIDC endpoint URL (with https://)"
  value       = aws_iam_openid_connect_provider.rosa_oidc.url
}

output "oidc_provider_arn" {
  description = "ARN of the AWS OIDC provider"
  value       = aws_iam_openid_connect_provider.rosa_oidc.arn
}

output "oidc_thumbprint" {
  description = "OIDC thumbprint"
  value       = rhcs_rosa_oidc_config.oidc_config.thumbprint
  sensitive   = true
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
      --replicas 3
  EOT
}

# Debug output to check OIDC URL format
output "debug_oidc_info" {
  description = "Debug information for OIDC configuration"
  value = {
    raw_oidc_url      = rhcs_rosa_oidc_config.oidc_config.oidc_endpoint_url
    full_oidc_url     = "https://${rhcs_rosa_oidc_config.oidc_config.oidc_endpoint_url}"
    provider_url      = aws_iam_openid_connect_provider.rosa_oidc.url
    oidc_hostname     = replace(aws_iam_openid_connect_provider.rosa_oidc.url, "https://", "")
  }
}
