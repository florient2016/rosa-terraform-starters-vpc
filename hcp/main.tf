############################
# VPC
############################
module "vpc" {
  source = "terraform-redhat/rosa-hcp/rhcs//modules/vpc"

  name_prefix              = var.name_prefix
  availability_zones_count = var.availability_zones_count
}

############################
# Cluster
############################
module "hcp" {
  source  = "terraform-redhat/rosa-hcp/rhcs"
  version = "1.6.2"

  cluster_name           = var.cluster_name
  openshift_version      = var.openshift_version
  machine_cidr           = module.vpc.cidr_block
  aws_subnet_ids         = concat(module.vpc.public_subnets, module.vpc.private_subnets)
  aws_availability_zones = module.vpc.availability_zones
  replicas               = length(module.vpc.availability_zones)

  // STS configuration
  create_account_roles  = var.create_account_roles
  account_role_prefix   = "${var.cluster_name}-account"
  create_oidc           = true
  create_operator_roles = true
  operator_role_prefix  = "${var.cluster_name}-operator"

  # Optional: Add tags
  tags = var.tags
}

############################
# HTPASSWD IDP
############################
module "htpasswd_idp" {
  source = "terraform-redhat/rosa-hcp/rhcs//modules/idp"

  cluster_id         = module.hcp.cluster_id
  name               = "htpasswd-idp"
  idp_type           = "htpasswd"
  htpasswd_idp_users = [
    {
      username = var.admin_username
      password = random_password.password.result
    }
  ]
}

resource "random_password" "password" {
  length  = 16
  special = true
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  min_upper   = 1
}