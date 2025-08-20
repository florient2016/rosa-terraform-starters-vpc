## rosa-cluster.tf
#
#resource "rhcs_cluster_rosa_classic" "rosa_cluster" {
#  name = "${var.prefix}-cluster"
#  
#  # Use the created roles
#  ocm_role_arn       = try(module.account_iam_resources.rosa_ocm_role_arn, aws_iam_role.ocm_role.arn)
#  installer_role_arn = try(module.account_iam_resources.rosa_installer_role_arn, aws_iam_role.account_roles["Installer-Role"].arn)
#  support_role_arn   = try(module.account_iam_resources.rosa_support_role_arn, aws_iam_role.account_roles["Support-Role"].arn)
#  controlplane_role_arn = try(module.account_iam_resources.rosa_controlplane_role_arn, aws_iam_role.account_roles["ControlPlane-Role"].arn)
#  worker_role_arn    = try(module.account_iam_resources.rosa_worker_role_arn, aws_iam_role.account_roles["Worker-Role"].arn)
#  
#  # AWS Configuration
#  cloud_region   = var.aws_region
#  aws_account_id = local.account_id
#  
#  # Cluster Configuration
#  openshift_version = local.openshift_version
#  replicas         = 3
#  
#  # Networking
#  machine_cidr = "10.0.0.0/16"
#  service_cidr = "172.30.0.0/16"
#  pod_cidr     = "10.128.0.0/14"
#  host_prefix  = 23
#  
#  # Compute
#  compute_machine_type = "m5.xlarge"
#  
#  # OIDC Configuration
#  sts = {
#    oidc_config_id   = local.oidc_config_id
#    operator_role_prefix = var.operator_role_prefix != "" ? var.operator_role_prefix : var.prefix
#    role_arn        = try(module.account_iam_resources.rosa_installer_role_arn, aws_iam_role.account_roles["Installer-Role"].arn)
#    support_role_arn = try(module.account_iam_resources.rosa_support_role_arn, aws_iam_role.account_roles["Support-Role"].arn)
#  }
#  
#  tags = local.common_tags
#
#  depends_on = [
#    module.account_iam_resources,
#    module.operator_iam_resources
#  ]
#}
