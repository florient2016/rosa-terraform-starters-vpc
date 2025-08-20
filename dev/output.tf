# outputs.tf - Additional cluster outputs

output "cluster_id" {
  description = "ID of the ROSA cluster"
  value       = rhcs_cluster_rosa_classic.rosa_cluster.id
}

output "cluster_name" {
  description = "Name of the ROSA cluster"
  value       = rhcs_cluster_rosa_classic.rosa_cluster.name
}

output "cluster_domain" {
  description = "Domain of the ROSA cluster"
  value       = rhcs_cluster_rosa_classic.rosa_cluster.domain
}

output "cluster_console_url" {
  description = "Console URL of the ROSA cluster"
  value       = rhcs_cluster_rosa_classic.rosa_cluster.console_url
}

output "cluster_api_url" {
  description = "API URL of the ROSA cluster"
  value       = rhcs_cluster_rosa_classic.rosa_cluster.api_url
}

output "cluster_state" {
  description = "State of the ROSA cluster"
  value       = rhcs_cluster_rosa_classic.rosa_cluster.state
}

output "cluster_admin_credentials" {
  description = "Cluster admin credentials (if created)"
  value = var.create_admin_user ? {
    username = rhcs_cluster_rosa_classic_admin_user.cluster_admin[0].username
    password = rhcs_cluster_rosa_classic_admin_user.cluster_admin[0].password
  } : null
  sensitive = true
}

output "cluster_connection_info" {
  description = "Information for connecting to the cluster"
  value = {
    console_url = rhcs_cluster_rosa_classic.rosa_cluster.console_url
    api_url     = rhcs_cluster_rosa_classic.rosa_cluster.api_url
    domain      = rhcs_cluster_rosa_classic.rosa_cluster.domain
    region      = rhcs_cluster_rosa_classic.rosa_cluster.cloud_region
    oidc_endpoint = "https://${rhcs_rosa_oidc_config.oidc_config.oidc_endpoint_url}"
  }
}
