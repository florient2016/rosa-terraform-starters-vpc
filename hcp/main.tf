terraform {
  required_version = ">= 1.4.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.38.0"
    }
    rhcs = {
      source  = "terraform-redhat/rhcs"
      version = ">= 1.6.2"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "rhcs" {}

data "aws_caller_identity" "current" {}

# Optional VPC creation
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 3.0.0"

  count = var.create_vpc ? 1 : 0

  name = "${var.name}-vpc"
  cidr = var.vpc_cidr
  azs  = var.aws_azs
  public_subnets  = var.vpc_public_subnets
  private_subnets = var.vpc_private_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { "Name" = "${var.name}-vpc" }
}

# Decide which subnets to pass to ROSA module
locals {
  subnet_ids = var.create_vpc ? module.vpc[0].private_subnets : var.existing_subnet_ids
}

module "rosa_hcp" {
  source  = "terraform-redhat/rosa-hcp/rhcs"

  cluster_name      = var.cluster_name
  openshift_version = var.openshift_version

  aws_subnet_ids         = local.subnet_ids
  aws_availability_zones = var.aws_azs
  machine_cidr           = var.machine_cidr
  replicas               = var.node_replicas

  create_account_roles  = true
  account_role_prefix   = "${var.name}-acct"
  create_oidc           = true
  create_operator_roles = true
  operator_role_prefix  = "${var.name}-op"

  create_admin_user           = var.create_admin_user
  admin_credentials_username  = "cluster-admin"
  admin_credentials_password  = var.admin_password
}

output "aws_account_id"           { value = data.aws_caller_identity.current.account_id }
output "hcp_cluster_id"           { value = module.rosa_hcp.cluster_id }
output "hcp_cluster_state"        { value = module.rosa_hcp.cluster_state }
output "hcp_api_url"              { value = module.rosa_hcp.cluster_api_url }
output "hcp_console_url"          { value = module.rosa_hcp.cluster_console_url }
output "hcp_domain"               { value = module.rosa_hcp.cluster_domain }
output "hcp_openshift_version"    { value = module.rosa_hcp.cluster_current_version }

output "hcp_account_role_prefix"  { value = module.rosa_hcp.account_role_prefix }
output "hcp_operator_role_prefix" { value = module.rosa_hcp.operator_role_prefix }
output "hcp_account_roles_arn"    { value = module.rosa_hcp.account_roles_arn }
output "hcp_operator_roles_arn"   { value = module.rosa_hcp.operator_roles_arn }
output "hcp_oidc_config_id"       { value = module.rosa_hcp.oidc_config_id }
output "hcp_oidc_endpoint_url"    { value = module.rosa_hcp.oidc_endpoint_url }

# VPC outputs
output "hcp_create_vpc"   { value = var.create_vpc }
output "hcp_vpc_id"       { value = var.create_vpc ? module.vpc[0].vpc_id : "" }
output "hcp_private_subnets" { value = var.create_vpc ? module.vpc[0].private_subnets : var.existing_subnet_ids }
output "hcp_public_subnets"  { value = var.create_vpc ? module.vpc[0].public_subnets  : [] }

output "hcp_admin_username" { value = module.rosa_hcp.cluster_admin_username }
output "hcp_admin_password" { value = module.rosa_hcp.cluster_admin_password, sensitive = true }
