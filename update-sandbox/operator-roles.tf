# operator-roles.tf - Rôles opérateur ROSA - SANS DUPLICATION avec rosa-prerequisites.tf

# Créer les rôles opérateur après OIDC config (nom unique)
resource "null_resource" "setup_operator_roles" {
  depends_on = [null_resource.create_account_roles, rhcs_rosa_oidc_config.oidc_config]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🔍 Configuration des rôles opérateur avec prefix ${local.auto_generated_prefix}..."
      
      # Vérifier si les rôles opérateur existent
      if rosa list operator-roles --prefix ${local.auto_generated_prefix} 2>/dev/null | grep -q "${local.auto_generated_prefix}"; then
        echo "✅ Les rôles opérateur existent déjà"
        rosa list operator-roles --prefix ${local.auto_generated_prefix}
      else
        echo "🔄 Création des rôles opérateur..."
        
        # Créer les rôles opérateur
        rosa create operator-roles \
          --mode auto \
          --yes \
          --prefix "${local.auto_generated_prefix}" \
          --oidc-config-id "${rhcs_rosa_oidc_config.oidc_config.id}" \
          --installer-role-arn "${local.auto_installer_role_arn}"
        
        if [ $? -eq 0 ]; then
          echo "✅ Rôles opérateur créés avec succès!"
          rosa list operator-roles --prefix ${local.auto_generated_prefix}
        else
          echo "❌ Erreur lors de la création des rôles opérateur"
          exit 1
        fi
      fi
    EOT
  }
  
  triggers = {
    prefix           = local.auto_generated_prefix
    oidc_config_id   = rhcs_rosa_oidc_config.oidc_config.id
    installer_role   = local.auto_installer_role_arn
  }
}

# Output pour les rôles opérateur
output "operator_roles_info" {
  description = "Informations sur les rôles opérateur"
  value = {
    prefix         = local.auto_generated_prefix
    oidc_config_id = rhcs_rosa_oidc_config.oidc_config.id
    created        = true
  }
  depends_on = [null_resource.setup_operator_roles]
}
