module "rosa_classic" {
  source = "terraform-redhat/rosa-classic/rhcs"

  # Idempotent IAM/OIDC bootstrap (module reuses if already present)
  create_account_roles  = true
  create_operator_roles = true
  create_oidc           = true

  # Cluster settings
  create_admin_user = false
  cluster_name      = var.cluster_name
  openshift_version = var.openshift_version
  region            = var.region
  multi_az          = var.multi_az
  public            = var.public
  replicas          = var.replicas
  machine_type      = var.machine_type

  # Networking
  create_vpc = true

  # Global AWS tags for all resources created by the module
  tags = {
    Name = "itssolutions"
  }
}

# Required outputs
output "console_url" {
  description = "OpenShift web console URL."
  value       = module.rosa_classic.console_url
}

output "cluster_id" {
  description = "ROSA cluster ID."
  value       = module.rosa_classic.cluster_id
}
