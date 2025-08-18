module "rosa_hcp" {
  source = "terraform-redhat/rosa-hcp/rhcs"
  version = "~> 1.6.0"

  # Required arguments
  cluster_name           = var.cluster_name
  openshift_version      = var.openshift_version
  
  # AWS Configuration
  aws_region            = var.region
  aws_availability_zones = var.multi_az ? ["${var.region}a", "${var.region}b", "${var.region}c"] : ["${var.region}a"]
  
  # Network Configuration
  create_vpc = var.create_vpc
  
  # When create_vpc = true, these are created automatically
  # When create_vpc = false, you need to provide existing subnet IDs
  aws_subnet_ids = var.create_vpc ? [] : var.aws_subnet_ids
  
  # Machine Configuration
  compute_machine_type = var.machine_type
  replicas            = var.replicas
  
  # Cluster Configuration
  destroy_timeout     = var.destroy_timeout
  upgrade_acknowledgements_for = var.upgrade_acknowledgements_for
  
  # Labels and tags
  tags = var.tags
}
