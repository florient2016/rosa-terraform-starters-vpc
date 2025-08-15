variable "name"              { type = string }
variable "cluster_name"      { type = string }
variable "aws_region"        { type = string }
variable "aws_azs"           { type = list(string) default = [] }
variable "openshift_version" { type = string       default = "4.14.24" }
variable "admin_password"    { type = string       sensitive = true }

# VPC options
variable "create_vpc"        { type = bool  default = false }
variable "vpc_cidr"          { type = string default = "10.0.0.0/16" }
variable "vpc_public_subnets" { type = list(string) default = ["10.0.0.0/24","10.0.1.0/24"] }
variable "vpc_private_subnets"{ type = list(string) default = ["10.0.10.0/24","10.0.11.0/24"] }
variable "existing_subnet_ids" { type = list(string) default = [] }
