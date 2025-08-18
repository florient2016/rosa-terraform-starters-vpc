module "rosa_classic" {
  source = "github.com/terraform-redhat/terraform-rhcs-rosa-classic"
  
  cluster_name          = var.cluster_name
  openshift_version     = var.openshift_version
  region                = var.region
  multi_az              = var.multi_az
  public                = var.public
  replicas              = var.replicas
  machine_type          = var.machine_type
  create_vpc            = var.create_vpc
  create_account_roles  = true
  create_operator_roles = true
  create_oidc           = true
  create_admin_user     = false
  tags                  = var.tags
}

# Output cluster information
output "cluster_id" {
  description = "ID of the created ROSA cluster"
  value       = module.rosa_classic.cluster_id
}

output "cluster_api_url" {
  description = "URL of the API server"
  value       = module.rosa_classic.cluster_api_url
}

output "cluster_console_url" {
  description = "URL of the OpenShift web console"
  value       = module.rosa_classic.cluster_console_url
}

output "cluster_domain" {
  description = "DNS domain of cluster"
  value       = module.rosa_classic.cluster_domain
}
