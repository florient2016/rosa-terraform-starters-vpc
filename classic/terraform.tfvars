# Values based on the provided base example - customize these for your environment
cluster_name          = "itssolutions"
openshift_version     = "4.16.13"  # Use a valid OpenShift version available in ROSA
account_role_prefix   = "itssolutions-account"
operator_role_prefix  = "itssolutions-operator"
aws_region            = "us-east-1"
availability_zones    = ["us-east-1a"]  # For multi-AZ, use e.g., ["us-east-1a", "us-east-1b", "us-east-1c"]
private               = false  # Public cluster
multi_az              = false  # Single AZ for simplicity

# VPC and subnet settings (adjust CIDRs and number of entries to match availability_zones)
vpc_cidr              = "10.0.0.0/16"
private_subnet_cidrs  = ["10.0.1.0/24"]  # One per AZ
public_subnet_cidrs   = ["10.0.101.0/24"]  # One per AZ

# Role names
ocm_role_name         = "itssolutions-ocm"
user_role_name        = "itssolutions-user"
