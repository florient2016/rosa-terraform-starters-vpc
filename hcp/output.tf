############################
# Cluster Outputs
############################
output "cluster_id" {
  description = "Unique identifier of the cluster"
  value       = module.hcp.cluster_id
}

output "cluster_name" {
  description = "Name of the cluster"
  value       = module.hcp.cluster_name
}

output "console_url" {
  description = "URL of the OpenShift web console"
  value       = module.hcp.console_url
}

output "api_url" {
  description = "URL of the API server"
  value       = module.hcp.api_url
}

output "domain" {
  description = "DNS domain of cluster"
  value       = module.hcp.domain
}

############################
# VPC Outputs
############################
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.cidr_block
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

############################
# Admin User Outputs
############################
output "admin_username" {
  description = "Admin username"
  value       = var.admin_username
}

output "admin_password" {
  description = "Admin password (sensitive)"
  value       = random_password.password.result
  sensitive   = true
}
