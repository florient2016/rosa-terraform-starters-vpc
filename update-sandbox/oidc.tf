# oidc.tf - Configuration OIDC avec prefix auto-généré

# Créer la configuration OIDC
resource "rhcs_rosa_oidc_config" "oidc_config" {
  depends_on = [null_resource.verify_account_roles]
  
  managed            = true
  secret_arn         = aws_secretsmanager_secret.rosa_token.arn
  issuer_url         = "" # Sera auto-généré pour OIDC managé
  installer_role_arn = local.auto_installer_role_arn  # Utiliser le prefix auto-généré
}

# Créer le secret AWS pour le token ROSA
resource "aws_secretsmanager_secret" "rosa_token" {
  name                    = "${local.auto_generated_prefix}-rosa-token"  # Utiliser le prefix auto-généré
  description             = "Token ROSA pour le cluster ${local.auto_generated_prefix}"
  recovery_window_in_days = 0 # Pour les environnements de lab
  
  tags = merge(local.common_tags, {
    Name   = "${local.auto_generated_prefix}-rosa-token"
    Prefix = local.auto_generated_prefix
  })
}

# Attendre que la configuration OIDC soit prête
resource "time_sleep" "wait_for_oidc" {
  depends_on = [rhcs_rosa_oidc_config.oidc_config]
  
  create_duration = "30s"
}

# Output pour la configuration OIDC
output "oidc_config_details" {
  description = "Détails de la configuration OIDC"
  value = {
    id         = rhcs_rosa_oidc_config.oidc_config.id
    issuer_url = rhcs_rosa_oidc_config.oidc_config.issuer_url
    secret_arn = aws_secretsmanager_secret.rosa_token.arn
    prefix     = local.auto_generated_prefix
  }
  depends_on = [time_sleep.wait_for_oidc]
}
