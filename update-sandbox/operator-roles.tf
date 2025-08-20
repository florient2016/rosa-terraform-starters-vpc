# operator-roles.tf - Rôles opérateur avec prefix auto-généré

# Créer les rôles opérateur avec ROSA CLI
resource "null_resource" "create_operator_roles" {
  depends_on = [
    time_sleep.wait_for_oidc,
    null_resource.verify_account_roles
  ]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🔍 Vérification des rôles opérateur existants avec prefix: ${local.auto_generated_prefix}..."
      
      # Vérifier si les rôles opérateur existent déjà
      if rosa list operator-roles --prefix ${local.auto_generated_prefix} | grep -q "${local.auto_generated_prefix}-"; then
        echo "✅ Les rôles opérateur avec le prefix '${local.auto_generated_prefix}' existent déjà"
        rosa list operator-roles --prefix ${local.auto_generated_prefix}
      else
        echo "🔄 Création des rôles opérateur avec prefix '${local.auto_generated_prefix}'..."
        
        # Créer les rôles opérateur
        rosa create operator-roles \
          --mode auto \
          --yes \
          --prefix "${local.auto_generated_prefix}" \
          --oidc-config-id "${rhcs_rosa_oidc_config.oidc_config.id}" \
          --installer-role-arn "${local.auto_installer_role_arn}"
        
        echo "✅ Rôles opérateur créés avec succès"
        echo "📋 Liste des rôles opérateur:"
        rosa list operator-roles --prefix ${local.auto_generated_prefix}
      fi
      
      echo ""
      echo "🏷️  PREFIX UTILISÉ: ${local.auto_generated_prefix}"
      echo ""
    EOT
  }
  
  triggers = {
    oidc_config_id = rhcs_rosa_oidc_config.oidc_config.id
    prefix         = local.auto_generated_prefix
  }
}

# Attendre que les rôles opérateur soient prêts
resource "time_sleep" "wait_for_operator_roles" {
  depends_on = [null_resource.create_operator_roles]
  
  create_duration = "30s"
}

# Vérifier les rôles opérateur
resource "null_resource" "verify_operator_roles" {
  depends_on = [time_sleep.wait_for_operator_roles]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🔍 Vérification des rôles opérateur avec prefix: ${local.auto_generated_prefix}..."
      echo "📋 Liste des rôles opérateur:"
      rosa list operator-roles --prefix ${local.auto_generated_prefix}
      echo "✅ Vérification des rôles opérateur terminée"
      echo ""
    EOT
  }
  
  triggers = {
    operator_roles = null_resource.create_operator_roles.id
    prefix         = local.auto_generated_prefix
  }
}
