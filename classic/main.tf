# Create VPC and subnets automatically
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs              = var.availability_zones
  private_subnets  = var.private_subnet_cidrs
  public_subnets   = var.public_subnet_cidrs

  enable_nat_gateway     = true
  single_nat_gateway     = length(var.availability_zones) == 1 ? true : false
  one_nat_gateway_per_az = length(var.availability_zones) > 1 ? true : false
  enable_vpn_gateway     = false

  tags = {
    Name = "itssolutions"
  }
}

# Create OCM role
resource "rhcs_rosa_ocm_role" "ocm_role" {
  name = var.ocm_role_name
  # Uses standard managed policies by default
}

# Create User role (linked to OCM role)
resource "rhcs_rosa_user_role" "user_role" {
  name           = var.user_role_name
  ocm_role_arns  = [rhcs_rosa_ocm_role.ocm_role.arn]
  # Uses standard managed policies by default
}

# Create ROSA Classic cluster (account roles, operator roles, OIDC created automatically)
module "rosa" {
  source = "terraform-redhat/rosa-classic/rhcs"

  cluster_name             = var.cluster_name
  openshift_version        = var.openshift_version
  account_role_prefix      = var.account_role_prefix
  operator_role_prefix     = var.operator_role_prefix
  aws_region               = var.aws_region
  aws_subnet_ids           = module.vpc.private_subnets  # Use auto-created private subnets
  availability_zones       = var.availability_zones
  private                  = var.private
  multi_az                 = var.multi_az
  create_account_roles     = true
  create_operator_roles    = true
  create_oidc              = true
  create_admin_user        = false

  tags = {
    Name = "itssolutions"
  }

  depends_on = [module.vpc]  # Ensure VPC/subnets exist before cluster creation
}

output "console_url" {
  description = "The URL of the ROSA cluster console"
  value       = module.rosa.console_url
}

output "cluster_id" {
  description = "The ID of the ROSA cluster"
  value       = module.rosa.cluster_id
}
