# Example values — replace with yours
name              = "apke"
cluster_name      = "apke-classic-euw1"
aws_region        = "eu-west-1"
aws_azs           = ["eu-west-1a","eu-west-1b","eu-west-1c"]
openshift_version = "4.14.24"
admin_password    = "ReplaceWithA14+CharsPass!"

# VPC options:
create_vpc = true
vpc_cidr = "10.30.0.0/16"
vpc_public_subnets = ["10.30.0.0/24","10.30.1.0/24","10.30.2.0/24"]
vpc_private_subnets = ["10.30.10.0/24","10.30.11.0/24","10.30.12.0/24"]
# If create_vpc = false, set existing_subnet_ids = ["subnet-aaa","subnet-bbb","subnet-ccc"]
