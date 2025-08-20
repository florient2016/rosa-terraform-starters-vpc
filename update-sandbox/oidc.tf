# oidc.tf - OIDC configuration for ROSA STS

# Create OIDC config
resource "rhcs_rosa_oidc_config" "oidc_config" {
  depends_on = [null_resource.verify_account_roles]
  
  managed            = true
  secret_arn         = aws_secretsmanager_secret.rosa_token.arn
  issuer_url         = "" # Will be auto-generated for managed OIDC
  installer_role_arn = local.installer_role_arn
}

# Create AWS secret for ROSA token (if needed)
resource "aws_secretsmanager_secret" "rosa_token" {
  name                    = "${var.prefix}-rosa-token"
  description             = "ROSA token for ${var.prefix} cluster"
  recovery_window_in_days = 0 # For lab environments
  
  tags = local.common_tags
}

# Wait for OIDC config to be ready
resource "time_sleep" "wait_for_oidc" {
  depends_on = [rhcs_rosa_oidc_config.oidc_config]
  
  create_duration = "30s"
}
