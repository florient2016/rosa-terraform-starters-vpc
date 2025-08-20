# rosa-prerequisites.tf - Adaptation pour Single AZ

# Générer un prefix unique avec indicateur Single AZ
resource "random_string" "prefix" {
  length  = 6  # Raccourci pour éviter les noms trop longs
  lower   = true
  upper   = false
  numeric = true
  special = false
  
  keepers = {
    environment     = var.environment
    region          = var.aws_region
    deployment_mode = var.single_az_deployment ? "saz" : "maz"
    availability_zone = var.single_az_deployment ? var.availability_zone : "multi"
  }
}

# Local pour le prefix avec indication Single AZ
locals {
  # Prefix avec indication du mode de déploiement
  deployment_suffix = var.single_az_deployment ? "saz" : "maz"
  auto_generated_prefix = "rosa-${local.deployment_suffix}-${random_string.prefix.result}"
  
  # ARNs avec le prefix auto-généré
  auto_installer_role_arn    = "arn:aws:iam::${local.account_id}:role/${local.auto_generated_prefix}-ManagedOpenShift-Installer-Role"
  auto_support_role_arn      = "arn:aws:iam::${local.account_id}:role/${local.auto_generated_prefix}-ManagedOpenShift-Support-Role"
  auto_controlplane_role_arn = "arn:aws:iam::${local.account_id}:role/${local.auto_generated_prefix}-ManagedOpenShift-ControlPlane-Role"
  auto_worker_role_arn       = "arn:aws:iam::${local.account_id}:role/${local.auto_generated_prefix}-ManagedOpenShift-Worker-Role"
  
  # Nom du cluster avec mode de déploiement
  auto_cluster_name = "${local.auto_generated_prefix}-cluster"
}

# Reste du code identique...
resource "null_resource" "create_account_roles" {
  depends_on = [random_string.prefix, local_file.generated_prefix]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🔍 Mode de déploiement: ${var.single_az_deployment ? "Single AZ (" + var.availability_zone + ")" : "Multi-AZ"}"
      echo "🔍 Prefix généré automatiquement: ${local.auto_generated_prefix}"
      echo "📝 Prefix sauvegardé dans: generated_prefix.txt"
      
      if rosa list account-roles --prefix ${local.auto_generated_prefix} | grep -q "${local.auto_generated_prefix}-ManagedOpenShift"; then
        echo "✅ Les rôles compte avec le prefix '${local.auto_generated_prefix}' existent déjà"
        rosa list account-roles --prefix ${local.auto_generated_prefix}
      else
        echo "🔄 Création des rôles compte pour ${var.single_az_deployment ? "Single AZ" : "Multi-AZ"}..."
        
        rosa create account-roles \
          --mode auto \
          --yes \
          --prefix "${local.auto_generated_prefix}" \
          --version "${var.openshift_version}" \
          --force-policy-creation
        
        echo "✅ Rôles compte créés avec succès pour ${var.single_az_deployment ? "Single AZ deployment" : "Multi-AZ deployment"}"
        rosa list account-roles --prefix ${local.auto_generated_prefix}
      fi
      
      echo ""
      echo "🏷️  PREFIX: ${local.auto_generated_prefix}"
      echo "🏗️  MODE: ${var.single_az_deployment ? "Single AZ (" + var.availability_zone + ")" : "Multi-AZ"}"
      echo ""
    EOT
  }
  
  triggers = {
    prefix               = local.auto_generated_prefix
    openshift_version    = var.openshift_version
    account_id          = local.account_id
    single_az_deployment = var.single_az_deployment
    availability_zone    = var.availability_zone
  }
}

# Le reste du fichier reste identique...
