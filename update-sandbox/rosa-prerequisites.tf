# rosa-prerequisites.tf - ROSA prerequisites avec prefix auto-généré - COMPLET

terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

# Générer un prefix unique automatiquement
resource "random_string" "prefix" {
  length  = 6
  lower   = true
  upper   = false
  numeric = true
  special = false
  
  keepers = {
    environment       = var.environment
    region           = var.aws_region
    deployment_mode  = var.single_az_deployment ? "saz" : "maz"
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

# RESSOURCE MANQUANTE 1: Sauvegarder le prefix généré dans un fichier local
resource "local_file" "generated_prefix" {
  filename = "${path.module}/generated_prefix.txt"
  content  = <<-EOT
# Prefix généré automatiquement par Terraform
# Généré le: ${timestamp()}
# Mode: ${var.single_az_deployment ? "Single AZ" : "Multi-AZ"}
${var.single_az_deployment ? "# Zone: ${var.availability_zone}" : "# Zones: Multi-AZ"}

PREFIX=${local.auto_generated_prefix}
CLUSTER_NAME=${local.auto_cluster_name}
DEPLOYMENT_MODE=${local.deployment_suffix}
REGION=${var.aws_region}
${var.single_az_deployment ? "AVAILABILITY_ZONE=${var.availability_zone}" : "MULTI_AZ=true"}

# Utilisation:
# export PREFIX=$(grep "^PREFIX=" generated_prefix.txt | cut -d'=' -f2)
# export CLUSTER_NAME=$(grep "^CLUSTER_NAME=" generated_prefix.txt | cut -d'=' -f2)
EOT
  
  depends_on = [random_string.prefix]
}

# RESSOURCE MANQUANTE 2: Vérifier les rôles compte existants
resource "null_resource" "verify_account_roles" {
  depends_on = [random_string.prefix, local_file.generated_prefix]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🔍 Mode de déploiement: ${var.single_az_deployment ? "Single AZ (" + var.availability_zone + ")" : "Multi-AZ"}"
      echo "🔍 Vérification de la connexion ROSA..."
      
      # Vérifier la connexion ROSA
      if ! rosa whoami > /dev/null 2>&1; then
        echo "❌ Erreur: Non connecté à ROSA. Vérifiez votre ROSA_TOKEN"
        echo "💡 Définissez: export ROSA_TOKEN=\"your-token\""
        exit 1
      fi
      
      echo "✅ Connexion ROSA OK"
      rosa whoami
      
      # Vérifier les quotas
      echo "🔍 Vérification des quotas AWS..."
      rosa verify quota --region ${var.aws_region} || echo "⚠️ Avertissement: Problème de quota détecté"
      
      echo "✅ Vérifications préliminaires terminées"
    EOT
  }
  
  triggers = {
    rosa_token_change = fileexists("${path.module}/.rosa_token_check") ? file("${path.module}/.rosa_token_check") : timestamp()
    region           = var.aws_region
    deployment_mode  = var.single_az_deployment ? "saz" : "maz"
  }
}

# Créer les rôles compte avec le prefix auto-généré
resource "null_resource" "create_account_roles" {
  depends_on = [random_string.prefix, local_file.generated_prefix, null_resource.verify_account_roles]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🔍 Prefix généré automatiquement: ${local.auto_generated_prefix}"
      echo "📝 Prefix sauvegardé dans: generated_prefix.txt"
      
      echo "🔍 Vérification des rôles compte existants avec prefix ${local.auto_generated_prefix}..."
      
      # Vérifier si les rôles existent déjà avec ce prefix
      if rosa list account-roles --prefix ${local.auto_generated_prefix} 2>/dev/null | grep -q "${local.auto_generated_prefix}-ManagedOpenShift"; then
        echo "✅ Les rôles compte avec le prefix '${local.auto_generated_prefix}' existent déjà"
        echo "📋 Rôles existants:"
        rosa list account-roles --prefix ${local.auto_generated_prefix}
      else
        echo "🔄 Création des rôles compte pour ${var.single_az_deployment ? "Single AZ deployment" : "Multi-AZ deployment"}..."
        
        # Créer les rôles compte
        rosa create account-roles \
          --mode auto \
          --yes \
          --prefix "${local.auto_generated_prefix}" \
          --version "${var.openshift_version}" \
          --force-policy-creation
        
        if [ $? -eq 0 ]; then
          echo "✅ Rôles compte créés avec succès!"
          echo "📋 Rôles créés:"
          rosa list account-roles --prefix ${local.auto_generated_prefix}
        else
          echo "❌ Erreur lors de la création des rôles compte"
          exit 1
        fi
      fi
      
      echo ""
      echo "📊 RÉSUMÉ DE LA CONFIGURATION:"
      echo "🏷️  PREFIX: ${local.auto_generated_prefix}"
      echo "🏗️  MODE: ${var.single_az_deployment ? "Single AZ (" + var.availability_zone + ")" : "Multi-AZ"}"
      echo "🌍 RÉGION: ${var.aws_region}"
      echo "📦 VERSION: ${var.openshift_version}"
      echo "💾 FICHIER: generated_prefix.txt"
      echo ""
    EOT
  }
  
  triggers = {
    prefix               = local.auto_generated_prefix
    openshift_version    = var.openshift_version
    account_id          = local.account_id
    single_az_deployment = var.single_az_deployment
    availability_zone    = var.single_az_deployment ? var.availability_zone : "multi-az"
    force_recreate      = timestamp()
  }
}

# Créer les rôles opérateur après les rôles compte
resource "null_resource" "create_operator_roles" {
  depends_on = [null_resource.create_account_roles, rhcs_rosa_oidc_config.oidc_config]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🔍 Vérification des rôles opérateur avec prefix ${local.auto_generated_prefix}..."
      
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
    force_recreate   = timestamp()
  }
}

# Output pour information
output "generated_prefix_info" {
  description = "Informations sur le prefix généré automatiquement"
  value = {
    prefix              = local.auto_generated_prefix
    cluster_name        = local.auto_cluster_name
    deployment_mode     = var.single_az_deployment ? "Single AZ" : "Multi-AZ"
    availability_zone   = var.single_az_deployment ? var.availability_zone : "Multi-AZ"
    generated_at        = timestamp()
    saved_to_file       = "generated_prefix.txt"
    installer_role_arn  = local.auto_installer_role_arn
    support_role_arn    = local.auto_support_role_arn
  }
}
