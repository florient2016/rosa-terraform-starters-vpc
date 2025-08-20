# main.tf - Provider configuration - UNIQUE

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
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

# Providers
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      Owner       = var.owner
      CreatedBy   = "Terraform"
      Prefix      = "rosa-generated"
    }
  }
}

provider "rhcs" {
  # Uses ROSA_TOKEN environment variable
}
