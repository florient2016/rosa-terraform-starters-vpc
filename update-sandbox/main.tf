# main.tf - Provider configuration

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    rhcs = {
      source  = "terraform-redhat/rhcs"
      version = "~> 1.6"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.11"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

# AWS Provider
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      Owner       = var.owner
      CreatedBy   = "Terraform"
      Prefix      = var.prefix
    }
  }
}

# RHCS Provider
provider "rhcs" {
  # Uses ROSA_TOKEN environment variable
}
