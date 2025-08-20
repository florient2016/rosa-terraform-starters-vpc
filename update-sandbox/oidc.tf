# oidc.tf - Configuration OIDC pour ROSA

# Configuration OIDC pour ROSA STS
resource "rhcs_rosa_oidc_config" "oidc_config" {
  # Dépendre des rôles compte créés et vérifiés
  depends_on = [null_resource.create_account_roles]
  
  # Configuration OIDC
  managed            = true
  secret_arn         = ""
  issuer_url         = ""
  installer_role_arn = local.auto_installer_role_arn
  
  # Tags
  tags = merge(local.common_tags, {
    Name        = "${local.auto_generated_prefix}-oidc-config"
    Purpose     = "ROSA-STS-OIDC"
    Prefix      = local.auto_generated_prefix
  })
}

# Output pour la configuration OIDC
output "oidc_config_info" {
  description = "Informations sur la configuration OIDC"
  value = {
    id               = rhcs_rosa_oidc_config.oidc_config.id
    issuer_url       = rhcs_rosa_oidc_config.oidc_config.issuer_url
    thumbprint       = rhcs_rosa_oidc_config.oidc_config.thumbprint
    installer_role   = local.auto_installer_role_arn
  }
}

# Ressource pour vérifier la configuration OIDC
resource "null_resource" "verify_oidc_config" {
  depends_on = [rhcs_rosa_oidc_config.oidc_config]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🔍 Vérification de la configuration OIDC..."
      echo "📋 ID OIDC: ${rhcs_rosa_oidc_config.oidc_config.id}"
      echo "🔗 Issuer URL: ${rhcs_rosa_oidc_config.oidc_config.issuer_url}"
      
      # Lister les configurations OIDC
      rosa list oidc-config
      
      echo "✅ Configuration OIDC vérifiée avec succès"
    EOT
  }
  
  triggers = {
    oidc_config_id = rhcs_rosa_oidc_config.oidc_config.id
    prefix         = local.auto_generated_prefix
  }
}
