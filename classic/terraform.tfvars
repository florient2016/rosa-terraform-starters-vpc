# Basic Configuration
region       = "us-east-1"
cluster_name = "my-rosa-hcp-cluster"

# Cluster Configuration
openshift_version = "4.14.6"
multi_az         = false
create_vpc       = true

# If create_vpc = false, uncomment and provide existing subnet IDs:
# aws_subnet_ids = ["subnet-12345", "subnet-67890"]

# Compute Configuration
machine_type = "m5.xlarge"
replicas     = 2

# Additional Configuration
destroy_timeout = 60

# Tags
tags = {
  Environment = "development"
  Project     = "rosa-hcp-demo"
  Owner       = "terraform"
}
