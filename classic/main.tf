terraform {
  required_version = ">= 1.4.6"
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 4.0" }
    rhcs = { source = "terraform-redhat/rhcs", version = ">= 1.6.2" }
  }
}

provider "aws" { region = var.aws_region }
provider "rhcs" {}

data "aws_caller_identity" "current" {}

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

locals {
  subnet_ids = var.create_vpc ? module.vpc[0].private_subnets : var.existing_subnet_ids
}

#module "rosa_classic" {
#  source  = "terraform-redhat/rosa-classic/rhcs"
module "rosa-classic" {
  source  = "terraform-redhat/rosa-classic/rhcs"
  version = "1.6.2"
  # insert the 2 required variables here

  cluster_name      = var.cluster_name
  openshift_version = var.openshift_version
  aws_availability_zones = var.aws_azs

  aws_subnet_ids = local.subnet_ids

  create_account_roles  = true
  account_role_prefix   = "${var.name}-acct"
  create_operator_roles = true
  operator_role_prefix  = "${var.name}-op"
  create_oidc           = true

  create_admin_user          = var.create_admin_user
  admin_credentials_username = "cluster-admin"
  admin_credentials_password = var.admin_password
}

output "aws_account_id"            { value = data.aws_caller_identity.current.account_id }
output "classic_cluster_id"        { value = module.rosa_classic.cluster_id }
output "classic_state"             { value = module.rosa_classic.state }
output "classic_console_url"       { value = module.rosa_classic.console_url }
output "classic_domain"            { value = module.rosa_classic.domain }
output "classic_current_version"   { value = module.rosa_classic.current_version }

output "classic_account_role_prefix" { value = module.rosa_classic.account_role_prefix }
output "classic_operator_role_prefix"{ value = module.rosa_classic.operator_role_prefix }
output "classic_account_roles_arn"   { value = module.rosa_classic.account_roles_arn }
output "classic_operator_roles_arn"  { value = module.rosa_classic.operator_roles_arn }
output "classic_oidc_config_id"      { value = module.rosa_classic.oidc_config_id }
output "classic_oidc_endpoint_url"   { value = module.rosa_classic.oidc_endpoint_url }

# VPC outputs
output "classic_create_vpc"   { value = var.create_vpc }
output "classic_vpc_id"       { value = var.create_vpc ? module.vpc[0].vpc_id : "" }
output "classic_private_subnets" { value = var.create_vpc ? module.vpc[0].private_subnets : var.existing_subnet_ids }
output "classic_public_subnets"  { value = var.create_vpc ? module.vpc[0].public_subnets  : [] }

output "classic_admin_username" { value = module.rosa_classic.admin_credentials_username }
output "classic_admin_password" { value = module.rosa_classic.admin_credentials_password, sensitive = true }
