# rosa-sts-roles.tf - Using data sources for existing roles

# Data sources for existing ROSA roles
data "aws_iam_role" "installer_role" {
  name = "${var.prefix}-HCP-ROSA-Installer-Role"
}

data "aws_iam_role" "support_role" {
  name = "${var.prefix}-HCP-ROSA-Support-Role"
}

data "aws_iam_role" "worker_role" {
  name = "${var.prefix}-HCP-ROSA-Worker-Role"
}

# Data source for existing instance profile
data "aws_iam_instance_profile" "worker_instance_profile" {
  name = "${var.prefix}-HCP-ROSA-Worker-Role"
}

# Output the existing resources
output "existing_roles" {
  value = {
    installer = data.aws_iam_role.installer_role.arn
    support   = data.aws_iam_role.support_role.arn
    worker    = data.aws_iam_role.worker_role.arn
  }
}
