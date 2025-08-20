# rosa-sts-roles.tf - Updated with correct ROSA HCP naming pattern

locals {
  # Extract major.minor version for role naming (e.g., "4.16" from "4.16.0")
  openshift_major_minor = join(".", slice(split(".", var.openshift_version), 0, 2))
  
  # Account role definitions with correct HCP ROSA naming
  account_roles = {
    installer = {
      name = "HCP-ROSA-Installer-Role"
    }
    support = {
      name = "HCP-ROSA-Support-Role"  
    }
    worker = {
      name = "HCP-ROSA-Worker-Role"
    }
  }
  
  common_tags = {
    Environment                  = "rosa-sts"
    ManagedBy                   = "terraform"
    Purpose                     = "rosa-cluster"
    Prefix                      = var.prefix
    "red-hat-managed"           = "true"
    "rosa.openshift.io/version" = var.openshift_version
  }
}

# Import existing roles created by ROSA CLI
resource "aws_iam_role" "account_roles" {
  for_each = local.account_roles
  
  name = "${var.prefix}-${each.value.name}"
  path = var.path
  
  # Use assume_role_policy from the existing role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = []
  })
  
  tags = merge(local.common_tags, {
    Name                         = "${var.prefix}-${each.value.name}"
    Type                         = "AccountRole" 
    Role                         = each.key
    OpenShiftVersion             = var.openshift_version
    OpenShiftMajorMinor          = local.openshift_major_minor
    "red-hat-managed"            = "true"
    "rosa.openshift.io/version"  = var.openshift_version
  })

  # Prevent Terraform from managing the assume role policy
  lifecycle {
    ignore_changes = [assume_role_policy]
  }
}

# Note: HCP ROSA doesn't use instance profiles for control plane
# Only worker instance profile if needed
resource "aws_iam_instance_profile" "worker_instance_profile" {
  name = "${var.prefix}-HCP-ROSA-Worker-Instance-Profile"
  role = aws_iam_role.account_roles["worker"].name
  path = var.path
  
  tags = merge(local.common_tags, {
    Name                         = "${var.prefix}-worker-instance-profile"
    Type                         = "InstanceProfile"
    OpenShiftVersion             = var.openshift_version
    OpenShiftMajorMinor          = local.openshift_major_minor
    "red-hat-managed"            = "true"
    "rosa.openshift.io/version"  = var.openshift_version
  })

  lifecycle {
    ignore_changes = [role]
  }
}
