terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    rhcs = {
      source  = "terraform-redhat/rhcs"
      version = ">= 1.5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "rhcs" {}
# Note: The rhcs provider automatically uses the RHCS_TOKEN environment variable for authentication.
# Ensure RHCS_TOKEN is exported in your environment before running Terraform.
