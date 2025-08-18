# Basic Configuration
cluster_name    = "itssolutions"
name_prefix     = "itssolutions"
aws_region      = "us-east-1"

# OpenShift Configuration
openshift_version = "4.16.45"
availability_zones_count = 3

# Account Roles (set to false if you created them manually before)
create_account_roles = true

# Admin User
admin_username = "cluster-admin"

# Tags
tags = {
  Environment = "development"
  Project     = "rosa-hcp-terraform"
  Owner       = "myteam"
}
