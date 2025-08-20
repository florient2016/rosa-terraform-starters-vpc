# outputs.tf - Outputs avec configuration Single AZ

locals {
  rosa_cluster_create_command = <<-EOT
# 🚀 Commande de Création du Cluster ROSA - ${upper(local.deployment_mode)}
# PREFIX AUTO-GÉNÉRÉ: ${local.auto_generated_prefix}
# MODE DE DÉPLOIEMENT: ${upper(local.deployment_mode)}
${var.single_az_deployment ? "# ZONE DE DISPONIBILITÉ: ${var.availability_zone}" : "# DÉPLOIEMENT MULTI-AZ"}

rosa create cluster \
  --cluster-name="${local.cluster_name}" \
  --sts \
  --mode=auto \
  --yes \
  --region="${var.aws_region}" \
  --version="${var.openshift_version}" \
  --compute-machine-type="${var.compute_machine_type}" \
  --compute-nodes=${var.compute_replicas} \
  --machine-cidr="${local.machine_cidr}" \
  --service-cidr="${local.service_cidr}" \
  --pod-cidr="${local.pod_cidr}" \
  --host-prefix=${local.host_prefix} \
  ${var.single_az_deployment ? "--availability-zones=${var.availability_zone}" : "--multi-az"} \
  --role-arn="${local.installer_role_arn}" \
  --support-role-arn="${local.support_role_arn}" \
  --controlplane-iam-role="${local.controlplane_role_arn}" \
  --worker-iam-role="${local.worker_role_arn}" \
  --operator-roles-prefix="${local.auto_generated_prefix}" \
  --oidc-config-id="${rhcs_rosa_oidc_config.oidc_config.id}" \
  --tags="Environment=${var.environment},Project=${var.project_name},Owner=${var.owner},CreatedBy=ROSA-CLI,Prefix=${local.auto_generated_prefix},DeploymentMode=${local.deployment_mode}"

EOT

  rosa_post_install_commands = <<-EOT
# 📋 Commandes Post-Installation - ${upper(local.deployment_mode)}

# Vérifier le statut du cluster
rosa describe cluster ${local.cluster_name}

# Surveiller l'installation
rosa logs install -c ${local.cluster_name} --watch

# Créer un admin cluster
rosa create admin -c ${local.cluster_name}

# Obtenir la console URL
rosa describe cluster ${local.cluster_name} | grep "Console URL"

# Vérifier les nœuds (Single AZ)
oc get nodes -o wide

# Vérifier la distribution des pods (Single AZ)
oc get pods -A -o wide | head -20

EOT
}

# Outputs principaux
output "deployment_configuration" {
  description = "Configuration de déploiement Single AZ"
  value = {
    prefix              = local.auto_generated_prefix
    cluster_name        = local.cluster_name
    deployment_mode     = local.deployment_mode
    availability_zone   = var.single_az_deployment ? var.availability_zone : "multi-az"
    region              = var.aws_region
    compute_replicas    = var.compute_replicas
    machine_type        = var.compute_machine_type
    generated_at        = timestamp()
  }
}

output "single_az_network_config" {
  description = "Configuration réseau pour Single AZ"
  value = {
    machine_cidr      = local.machine_cidr
    service_cidr      = local.service_cidr
    pod_cidr          = local.pod_cidr
    host_prefix       = local.host_prefix
    availability_zone = var.single_az_deployment ? var.availability_zone : null
    deployment_mode   = local.deployment_mode
  }
}

output "account_roles" {
  description = "ARNs des rôles compte"
  value = {
    installer_role    = local.installer_role_arn
    support_role      = local.support_role_arn
    controlplane_role = local.controlplane_role_arn
    worker_role       = local.worker_role_arn
  }
}

output "rosa_cluster_create_command" {
  description = "Commande complète de création du cluster ROSA Single AZ"
  value       = local.rosa_cluster_create_command
}

output "rosa_post_install_commands" {
  description = "Commandes post-installation pour Single AZ"
  value       = local.rosa_post_install_commands
}

output "verification_commands" {
  description = "Commandes de vérification Single AZ"
  value = <<-EOT
# 🔍 Commandes de Vérification - ${upper(local.deployment_mode)}
# PREFIX AUTO-GÉNÉRÉ: ${local.auto_generated_prefix}
${var.single_az_deployment ? "# ZONE: ${var.availability_zone}" : "# MODE: Multi-AZ"}

# Vérifier la connexion ROSA
rosa whoami

# Lister les rôles compte
rosa list account-roles --prefix ${local.auto_generated_prefix}

# Lister les rôles opérateur
rosa list operator-roles --prefix ${local.auto_generated_prefix}

# Vérifier la configuration OIDC
rosa list oidc-config

# Vérifier les quotas
rosa verify quota --region ${var.aws_region}

# Vérifier les versions disponibles
rosa list versions --channel-group stable

# Lire le prefix généré
cat generated_prefix.txt

# Vérifier l'AZ sélectionnée
aws ec2 describe-availability-zones --zone-names ${var.availability_zone} --region ${var.aws_region}

EOT
}
