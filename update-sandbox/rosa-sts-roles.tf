# rosa-sts-roles.tf - Updated to import existing ROSA-created roles

locals {
  # Extract major.minor version for role naming (e.g., "4.16" from "4.16.0")
  openshift_major_minor = join(".", slice(split(".", var.openshift_version), 0, 2))
  
  # Account role definitions - for import only, don't manage policies
  account_roles = {
    installer = {
      name = "ManagedOpenShift-Installer-Role"
    }
    support = {
      name = "ManagedOpenShift-Support-Role"
    }
    controlplane = {
      name = "ManagedOpenShift-ControlPlane-Role"
    }
    worker = {
      name = "ManagedOpenShift-Worker-Role"
    }
  }
}

# Import existing roles created by ROSA CLI - don't recreate them
resource "aws_iam_role" "account_roles" {
  for_each = local.account_roles
  
  name = "${var.prefix}-${local.openshift_major_minor}-${each.value.name}"
  path = var.path
  
  # Use assume_role_policy from the existing role
  # This will be populated when you import the role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = []
  })
  
  tags = merge(local.common_tags, {
    Name                         = "${var.prefix}-${local.openshift_major_minor}-${each.key}"
    Type                         = "AccountRole" 
    Role                         = each.key
    OpenShiftVersion             = var.openshift_version
    OpenShiftMajorMinor          = local.openshift_major_minor
    "red-hat-managed"            = "true"
    "rosa.openshift.io/version"  = var.openshift_version
  })

  # Prevent Terraform from managing the assume role policy
  # since ROSA CLI already set it correctly
  lifecycle {
    ignore_changes = [assume_role_policy]
  }
}

# Import existing instance profiles created by ROSA CLI
resource "aws_iam_instance_profile" "controlplane_instance_profile" {
  name = "${var.prefix}-${local.openshift_major_minor}-ManagedOpenShift-ControlPlane-Instance-Profile"
  role = aws_iam_role.account_roles["controlplane"].name
  path = var.path
  
  tags = merge(local.common_tags, {
    Name                         = "${var.prefix}-${local.openshift_major_minor}-controlplane-instance-profile"
    Type                         = "InstanceProfile"
    OpenShiftVersion             = var.openshift_version
    OpenShiftMajorMinor          = local.openshift_major_minor
    "red-hat-managed"            = "true"
    "rosa.openshift.io/version"  = var.openshift_version
  })

  # Don't recreate if it already exists
  lifecycle {
    ignore_changes = [role]
  }
}

resource "aws_iam_instance_profile" "worker_instance_profile" {
  name = "${var.prefix}-${local.openshift_major_minor}-ManagedOpenShift-Worker-Instance-Profile"
  role = aws_iam_role.account_roles["worker"].name
  path = var.path
  
  tags = merge(local.common_tags, {
    Name                         = "${var.prefix}-${local.openshift_major_minor}-worker-instance-profile"
    Type                         = "InstanceProfile"
    OpenShiftVersion             = var.openshift_version
    OpenShiftMajorMinor          = local.openshift_major_minor
    "red-hat-managed"            = "true"
    "rosa.openshift.io/version"  = var.openshift_version
  })

  # Don't recreate if it already exists
  lifecycle {
    ignore_changes = [role]
  }
}
