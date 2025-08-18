# Basic cluster configuration
cluster_name      = "my-rosa-hcp-cluster"
openshift_version = "4.14.15"
region           = "us-east-1"

# Cluster topology
multi_az    = false
public      = true
replicas    = 2
machine_type = "m5.xlarge"

# Infrastructure
create_vpc = true

# Tags
tags = {
  Environment = "its-development"
  Project     = "its-rosa-hcp-demo"
  Owner       = "its-platform-team"
  ManagedBy   = "its-terraform"
  CostCenter  = "its-engineering"
}
