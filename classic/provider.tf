terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    rhcs = {
      source  = "terraform-redhat/rhcs"
      version = ">= 1.6.0"
    }
  }
}

# AWS region is taken from the 'region' variable (can also be set via AWS_REGION env).
provider "aws" {
  region = var.region
}

# RHCS provider reads the token only from the RHCS_TOKEN environment variable.
# Do not pass tokens via variables to avoid secrets in code/state.
provider "rhcs" {}
