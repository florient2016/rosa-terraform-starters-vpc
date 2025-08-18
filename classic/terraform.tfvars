# Required variables
cluster_name = "my-rosa-labs"

# Optional variables (uncomment and modify as needed)
# openshift_version = "4.14.0"
region = "us-east-1"
# multi_az = true
# public = true
# replicas = 2
# machine_type = "m5.xlarge"
# create_vpc = true

# Example tags
tags = {
  Environment = "its-development"
  Project     = "its-rosa-demo"
  Owner       = "its-platform-team"
}
