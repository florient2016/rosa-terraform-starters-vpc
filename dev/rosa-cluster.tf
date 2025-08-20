# rosa-cluster.tf - Complete working cluster creation

# Local values for cluster configuration
locals {
  cluster_name = "${var.prefix}-cluster"
  
  # Availability zones for multi-AZ deployment
  availability_zones = data.aws_availability_zones.available.names
  
  # Compute node configuration
  compute_nodes = {
    machine_type  = var.compute_machine_type
    replicas      = var.compute_replicas
    min_replicas  = var.compute_min_replicas
    max_replicas  = var.compute_max_replicas
  }
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
  
  filter {
    name   = "region-name"
    values = [var.aws_region]
  }
}

# Wait for all IAM resources to be ready
resource "time_sleep" "wait_for_iam" {
  depends_on = [
    aws_iam_role.account_roles,
    aws_iam_role_policy.account_role_policies,
    aws_iam_instance_profile.controlplane_instance_profile,
    aws_iam_instance_profile.worker_instance_profile,
    aws_iam_role.operator_roles,
    aws_iam_role_policy.operator_role_policies
  ]
  
  create_duration = "30s"
}

# Create ROSA cluster
resource "rhcs_cluster_rosa_classic" "rosa_cluster" {
  depends_on = [
    time_sleep.wait_for_iam,
    aws_iam_openid_connect_provider.rosa_oidc
  ]
  
  # Basic cluster configuration
  name           = local.cluster_name
  cloud_region   = var.aws_region
  aws_account_id = local.account_id
  
  # OpenShift version
  version = var.openshift_version
  
  # STS configuration
  sts = {
    installer_role_arn      = aws_iam_role.account_roles["installer"].arn
    support_role_arn        = aws_iam_role.account_roles["support"].arn
    instance_iam_roles = {
      master_role_arn = aws_iam_role.account_roles["controlplane"].arn
      worker_role_arn = aws_iam_role.account_roles["worker"].arn
    }
    operator_role_prefix = var.prefix
    oidc_config_id      = rhcs_rosa_oidc_config.oidc_config.id
  }
  
  # Network configuration
  availability_zones = var.multi_az ? slice(local.availability_zones, 0, 3) : [local.availability_zones[0]]
  
  # Subnet configuration (if using existing VPC)
  dynamic "aws_subnet_ids" {
    for_each = var.subnet_ids != null ? [1] : []
    content {
      subnet_ids = var.subnet_ids
    }
  }
  
  # Compute nodes configuration
  compute_machine_type = local.compute_nodes.machine_type
  replicas            = local.compute_nodes.replicas
  
  # Autoscaling configuration
  dynamic "autoscaling" {
    for_each = var.enable_autoscaling ? [1] : []
    content {
      enabled = true
    }
  }
  
  # Control plane configuration
  multi_az = var.multi_az
  
  # Additional properties
  properties = {
    rosa_creator_arn = data.aws_caller_identity.current.arn
  }
  
  # Disable workload monitoring if specified
  disable_workload_monitoring = var.disable_workload_monitoring
  
  # Tags
  tags = merge(local.common_tags, var.additional_cluster_tags)
  
  # Lifecycle management
  lifecycle {
    ignore_changes = [
      # Ignore changes to these as they may be managed externally
      tags,
      properties
    ]
    
    # Prevent accidental cluster deletion
    prevent_destroy = var.prevent_cluster_destroy
  }
  
  # Timeouts
  timeouts {
    create = "60m"
    update = "60m" 
    delete = "60m"
  }
}

# Wait for cluster to be ready
resource "time_sleep" "wait_for_cluster" {
  depends_on = [rhcs_cluster_rosa_classic.rosa_cluster]
  
  create_duration = "5m"
}

# Create cluster admin user (optional)
resource "rhcs_cluster_rosa_classic_admin_user" "cluster_admin" {
  count = var.create_admin_user ? 1 : 0
  
  cluster = rhcs_cluster_rosa_classic.rosa_cluster.id
  
  depends_on = [time_sleep.wait_for_cluster]
  
  timeouts {
    create = "10m"
  }
}

# Machine pools for additional worker node groups (optional)
resource "rhcs_machine_pool" "additional_workers" {
  for_each = var.additional_machine_pools
  
  cluster = rhcs_cluster_rosa_classic.rosa_cluster.id
  name    = each.key
  
  machine_type = each.value.machine_type
  replicas     = each.value.replicas
  
  # Autoscaling
  dynamic "autoscaling" {
    for_each = each.value.enable_autoscaling ? [1] : []
    content {
      enabled      = true
      min_replicas = each.value.min_replicas
      max_replicas = each.value.max_replicas
    }
  }
  
  # Labels and taints
  labels = each.value.labels
  taints = each.value.taints
  
  # Availability zones
  availability_zones = each.value.availability_zones != null ? each.value.availability_zones : (
    var.multi_az ? slice(local.availability_zones, 0, 3) : [local.availability_zones[0]]
  )
  
  depends_on = [time_sleep.wait_for_cluster]
}

# Identity provider (optional)
resource "rhcs_identity_provider" "htpasswd_idp" {
  count = var.create_htpasswd_idp ? 1 : 0
  
  cluster = rhcs_cluster_rosa_classic.rosa_cluster.id
  name    = "htpasswd-idp"
  
  htpasswd = {
    users = var.htpasswd_users
  }
  
  depends_on = [time_sleep.wait_for_cluster]
}
