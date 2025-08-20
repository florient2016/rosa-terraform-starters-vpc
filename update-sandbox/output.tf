# outputs.tf - Outputs with ROSA cluster creation commands

locals {
  rosa_cluster_create_command = <<-EOT
# 🚀 ROSA Cluster Creation Command
# Copy and run this command to create your ROSA cluster:

rosa create cluster \
  --cluster-name="${local.cluster_name}" \
  --sts \
  --mode=auto \
  --yes \
  --region="${var.aws_region}" \
  --version="${var.openshift_version}" \
  --compute-machine-type="${var.compute_machine_type}" \
  --compute-nodes=${var.compute_replicas} \
  --machine-cidr="${local.machine_cidr}" \
  --service-cidr="${local.service_cidr}" \
  --pod-cidr="${local.pod_cidr}" \
  --host-prefix=${local.host_prefix} \
  ${var.multi_az ? "--multi-az" : ""} \
  --role-arn="${local.installer_role_arn}" \
  --support-role-arn="${local.support_role_arn}" \
  --controlplane-iam-role="${local.controlplane_role_arn}" \
  --worker-iam-role="${local.worker_role_arn}" \
  --operator-roles-prefix="${var.prefix}" \
  --oidc-config-id="${rhcs_rosa_oidc_config.oidc_config.id}" \
  --tags="Environment=${var.environment},Project=${var.project_name},Owner=${var.owner},CreatedBy=ROSA-CLI"

EOT

  rosa_post_install_commands = <<-EOT
# 📋 Post-Installation Commands
# After cluster creation is complete, run these commands:

# 1. Check cluster status
rosa describe cluster ${local.cluster_name}

# 2. Monitor installation logs
rosa logs install -c ${local.cluster_name} --watch

# 3. Create cluster admin user
rosa create admin -c ${local.cluster_name}

# 4. Create additional users (optional)
rosa create idp -c ${local.cluster_name} -t htpasswd --username=developer --password=mypassword123

# 5. Get console URL
rosa describe cluster ${local.cluster_name} | grep "Console URL"

# 6. Delete cluster (when done)
rosa delete cluster -c ${local.cluster_name} --yes

EOT
}

# Terraform outputs
output "account_id" {
  description = "AWS Account ID"
  value       = local.account_id
}

output "region" {
  description = "AWS Region"
  value       = var.aws_region
}

output "prefix" {
  description = "Resource prefix"
  value       = var.prefix
}

output "openshift_version" {
  description = "OpenShift version"
  value       = var.openshift_version
}

output "oidc_config_id" {
  description = "OIDC Configuration ID"
  value       = rhcs_rosa_oidc_config.oidc_config.id
}

output "cluster_name" {
  description = "Cluster name that will be created"
  value       = local.cluster_name
}

output "account_role_arns" {
  description = "Account role ARNs"
  value = {
    installer_role    = local.installer_role_arn
    support_role      = local.support_role_arn
    controlplane_role = local.controlplane_role_arn
    worker_role       = local.worker_role_arn
  }
}

output "network_config" {
  description = "Network configuration"
  value = {
    machine_cidr = local.machine_cidr
    service_cidr = local.service_cidr
    pod_cidr     = local.pod_cidr
    host_prefix  = local.host_prefix
  }
}

output "rosa_cluster_create_command" {
  description = "Complete ROSA cluster creation command"
  value       = local.rosa_cluster_create_command
}

output "rosa_post_install_commands" {
  description = "Post-installation commands"
  value       = local.rosa_post_install_commands
}

output "verification_commands" {
  description = "Commands to verify prerequisites"
  value = <<-EOT
# 🔍 Verification Commands
# Run these commands to verify everything is ready:

# Check ROSA login
rosa whoami

# List account roles
rosa list account-roles --prefix ${var.prefix}

# List operator roles
rosa list operator-roles --prefix ${var.prefix}

# List OIDC configs
rosa list oidc-config

# Verify quota
rosa verify quota --region ${var.aws_region}

# Check available versions
rosa list versions --channel-group stable

EOT
}
