# locals.tf - Valeurs locales avec configuration Single AZ

locals {
  # ID du compte AWS
  account_id = data.aws_caller_identity.current.account_id
  
  # Tags communs
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    CreatedBy   = "Terraform"
    Region      = var.aws_region
    Deployment  = var.single_az_deployment ? "SingleAZ" : "MultiAZ"
  }
  
  # Utiliser le prefix auto-généré
  effective_prefix = local.auto_generated_prefix
  
  # ARNs des rôles avec le prefix auto-généré
  installer_role_arn    = local.auto_installer_role_arn
  support_role_arn      = local.auto_support_role_arn
  controlplane_role_arn = local.auto_controlplane_role_arn
  worker_role_arn       = local.auto_worker_role_arn
  
  # Nom du cluster avec prefix auto-généré et indicateur Single AZ
  cluster_name = "${local.auto_generated_prefix}-${var.single_az_deployment ? "singleaz" : "multiaz"}-cluster"
  
  # Configuration réseau
  machine_cidr = var.machine_cidr
  service_cidr = var.service_cidr
  pod_cidr     = var.pod_cidr
  host_prefix  = var.host_prefix
  
  # Configuration Single AZ
  deployment_mode = var.single_az_deployment ? "single-az" : "multi-az"
  availability_zone = var.single_az_deployment ? var.availability_zone : null
  
  # Validation pour Single AZ
  validate_single_az = var.single_az_deployment ? (
    length(var.availability_zone) > 0 ? true : 
    error("availability_zone must be specified when single_az_deployment is true")
  ) : true
}

# Sources de données
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_partition" "current" {}

# Vérifier que l'AZ spécifiée existe
data "aws_availability_zone" "selected" {
  count = var.single_az_deployment ? 1 : 0
  name  = var.availability_zone
}
