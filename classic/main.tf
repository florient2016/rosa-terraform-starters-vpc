# Account-wide IAM roles (run once per AWS account)
module "account_iam_resources" {
  source = "terraform-redhat/rosa-hcp/rhcs//modules/account-iam-resources"
  version = "~> 1.6.0"
  
  account_role_prefix = "ManagedOpenShift"
  #openshift_version   = var.openshift_version
  tags                = var.tags
}

# Operator roles and OIDC (per cluster)
module "operator_roles" {
  source = "terraform-redhat/rosa-hcp/rhcs//modules/operator-roles"
  version = "~> 1.6.0"
  
  account_role_prefix    = module.account_iam_resources.account_role_prefix
  operator_role_prefix   = "${var.cluster_name}-operator"
  oidc_endpoint_url     = module.rosa_hcp.oidc_endpoint_url
  tags                  = var.tags
}

# ROSA HCP Cluster
module "rosa_hcp" {
  source = "terraform-redhat/rosa-hcp/rhcs"
  version = "~> 1.6.0"
  
  depends_on = [
    module.account_iam_resources,
    module.operator_roles
  ]

  cluster_name           = var.cluster_name
  openshift_version      = var.openshift_version
  #aws_region            = var.region
  aws_availability_zones = var.multi_az ? ["${var.region}a", "${var.region}b", "${var.region}c"] : ["${var.region}a"]
  
  # IAM roles
  installer_role_arn       = module.account_iam_resources.installer_role_arn
  support_role_arn        = module.account_iam_resources.support_role_arn  
  controlplane_role_arn   = module.account_iam_resources.controlplane_role_arn
  worker_role_arn         = module.account_iam_resources.worker_role_arn
  
  # Operator roles
  operator_role_prefix    = module.operator_roles.operator_role_prefix
  oidc_config_id         = module.operator_roles.oidc_config_id
  
  # Network
  #create_vpc = var.create_vpc
  aws_subnet_ids = var.create_vpc ? [] : var.aws_subnet_ids
  
  # Compute
  compute_machine_type = var.machine_type
  replicas            = var.replicas
  
  tags = var.tags
}
