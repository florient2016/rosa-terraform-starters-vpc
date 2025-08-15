# Terraform configuration for deploying a ROSA (Red Hat OpenShift Service on AWS) cluster
# with an optional VPC setup.

# Define required Terraform version and providers
terraform {
  required_version = ">= 1.4.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    rhcs = {
      source  = "terraform-redhat/rhcs"
      version = "1.6.2"
    }
  }
}

# Configure the AWS provider with the specified region
provider "aws" {
  region = var.aws_region
}

# Configure the RHCS provider for ROSA
provider "rhcs" {}

# Retrieve the current AWS account ID
data "aws_caller_identity" "current" {}

# Create a VPC (if var.create_vpc is true) using the AWS VPC module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  count = var.create_vpc ? 1 : 0

  name = "${var.name}-vpc"
  cidr = var.vpc_cidr
  azs  = var.aws_azs
  public_subnets  = var.vpc_public_subnets
  private_subnets = var.vpc_private_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    "Name" = "${var.name}-vpc"
    "Environment" = var.environment
  }
}

# Dynamically select subnet IDs based on whether a VPC is created
locals {
  subnet_ids = var.create_vpc ? module.vpc[0].private_subnets : var.existing_subnet_ids
}

# Deploy a ROSA Classic cluster
module "rosa-classic" {
  source  = "terraform-redhat/rosa-classic/rhcs"
  version = "1.6.2"

  cluster_name          = var.cluster_name
  openshift_version     = var.openshift_version
  aws_availability_zones = var.aws_azs
  aws_subnet_ids        = local.subnet_ids

  create_account_roles   = true
  account_role_prefix   = "${var.name}-acct"
  create_operator_roles  = true
  operator_role_prefix  = "${var.name}-op"
  create_oidc           = true
  create_user           = true

  create_admin_user          = var.create_admin_user
  admin_credentials_username = "cluster-admin"
  admin_credentials_password = var.admin_password
}

# Output key information about the ROSA cluster and VPC
output "aws_account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "classic_cluster_id" {
  description = "ROSA cluster ID"
  value       = module.rosa-classic.cluster_id
}

output "classic_state" {
  description = "ROSA cluster state"
  value       = module.rosa-classic.state
}

output "classic_console_url" {
  description = "ROSA cluster console URL"
  value       = module.rosa-classic.console_url
}

output "classic_domain" {
  description = "ROSA cluster domain"
  value       = module.rosa-classic.domain
}

output "classic_current_version" {
  description = "ROSA cluster current version"
  value       = module.rosa-classic.current_version
}

output "classic_account_role_prefix" {
  description = "Prefix for ROSA account roles"
  value       = module.rosa-classic.account_role_prefix
}

output "classic_operator_role_prefix" {
  description = "Prefix for ROSA operator roles"
  value       = module.rosa-classic.operator_role_prefix
}

output "classic_account_roles_arn" {
  description = "ARNs of ROSA account roles"
  value       = module.rosa-classic.account_roles_arn
}

output "classic_operator_roles_arn" {
  description = "ARNs of ROSA operator roles"
  value       = module.rosa-classic.operator_roles_arn
}

output "classic_oidc_config_id" {
  description = "OIDC configuration ID for ROSA"
  value       = module.rosa-classic.oidc_config_id
}

output "classic_oidc_endpoint_url" {
  description = "OIDC endpoint URL for ROSA"
  value       = module.rosa-classic.oidc_endpoint_url
}

output "classic_create_vpc" {
  description = "Whether a VPC was created"
  value       = var.create_vpc
}

output "classic_vpc_id" {
  description = "ID of the created VPC (if applicable)"
  value       = var.create_vpc ? module.vpc[0].vpc_id : ""
}

output "classic_private_subnets" {
  description = "Private subnet IDs"
  value       = var.create_vpc ? module.vpc[0].private_subnets : var.existing_subnet_ids
}

output "classic_public_subnets" {
  description = "Public subnet IDs"
  value       = var.create_vpc ? module.vpc[0].public_subnets : []
}

output "classic_admin_username" {
  description = "ROSA admin username"
  value       = module.rosa-classic.admin_credentials_username
}

output "classic_admin_password" {
  description = "ROSA admin password"
  value       = module.rosa-classic.admin_credentials_password
  sensitive   = true
}