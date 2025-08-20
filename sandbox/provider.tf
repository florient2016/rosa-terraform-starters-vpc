# versions.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    rhcs = {
      source  = "terraform-redhat/rhcs"
      version = ">= 1.6.2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "rhcs" {
  # Configure with your Red Hat account token
  # export RHCS_TOKEN="your-offline-token"
}

provider "aws" {
  region = var.aws_region
}
