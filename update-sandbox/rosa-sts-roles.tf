# rosa-sts-roles.tf - Updated with AWS managed policies for ROSA 4.16

# Get the latest available OpenShift version if not specified
locals {
  # Extract major.minor version for role naming (e.g., "4.16" from "4.16.0")
  openshift_major_minor = join(".", slice(split(".", var.openshift_version), 0, 2))
  
  # Account role definitions with correct AWS managed policies
  account_roles = {
    installer = {
      name = "ManagedOpenShift-Installer-Role"
      managed_policies = [
        "arn:aws:iam::aws:policy/service-role/ROSAInstallerPolicy"
      ]
      trust_policy_statements = [{
        effect = "Allow"
        principals = {
          type        = "AWS"
          identifiers = ["arn:${local.partition}:iam::${local.red_hat_aws_account}:root"]
        }
        actions = ["sts:AssumeRole"]
        condition = {
          test     = "StringEquals" 
          variable = "sts:ExternalId"
          values   = [random_uuid.external_id.result]
        }
      }]
    }
    support = {
      name = "ManagedOpenShift-Support-Role"
      managed_policies = [
        "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
      ]
      trust_policy_statements = [{
        effect = "Allow"
        principals = {
          type        = "AWS"
          identifiers = ["arn:${local.partition}:iam::${local.red_hat_aws_account}:root"]
        }
        actions = ["sts:AssumeRole"]
        condition = {
          test     = "StringEquals"
          variable = "sts:ExternalId" 
          values   = [random_uuid.external_id.result]
        }
      }]
    }
    controlplane = {
      name = "ManagedOpenShift-ControlPlane-Role"
      managed_policies = [
        "arn:aws:iam::aws:policy/service-role/ROSAControlPlanePolicy"
      ]
      trust_policy_statements = [{
        effect = "Allow"
        principals = {
          type        = "Service"
          identifiers = ["ec2.amazonaws.com"]
        }
        actions = ["sts:AssumeRole"]
      }]
    }
    worker = {
      name = "ManagedOpenShift-Worker-Role"
      managed_policies = [
        "arn:aws:iam::aws:policy/service-role/ROSAWorkerInstancePolicy"
      ]
      trust_policy_statements = [{
        effect = "Allow"
        principals = {
          type        = "Service"
          identifiers = ["ec2.amazonaws.com"]
        }
        actions = ["sts:AssumeRole"]
      }]
    }
  }
}

# Generate external ID for Red Hat role assumption
resource "random_uuid" "external_id" {}

# Create trust policies for account roles
data "aws_iam_policy_document" "account_trust_policies" {
  for_each = local.account_roles
  
  dynamic "statement" {
    for_each = each.value.trust_policy_statements
    content {
      effect  = statement.value.effect
      actions = statement.value.actions
      
      principals {
        type        = statement.value.principals.type
        identifiers = statement.value.principals.identifiers
      }
      
      dynamic "condition" {
        for_each = can(statement.value.condition) ? [statement.value.condition] : []
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

# Create account roles with OpenShift version in the name
resource "aws_iam_role" "account_roles" {
  for_each = local.account_roles
  
  name = "${var.prefix}-${local.openshift_major_minor}-${each.value.name}"
  path = var.path
  
  assume_role_policy   = data.aws_iam_policy_document.account_trust_policies[each.key].json
  max_session_duration = 3600
  
  tags = merge(local.common_tags, {
    Name                     = "${var.prefix}-${local.openshift_major_minor}-${each.value.name}"
    Type                     = "AccountRole"
    Role                     = each.key
    OpenShiftVersion         = var.openshift_version
    OpenShiftMajorMinor      = local.openshift_major_minor
    "red-hat-managed"        = "true"
    "rosa.openshift.io/version" = var.openshift_version
  })
}

# Attach AWS managed policies to roles
resource "aws_iam_role_policy_attachment" "account_role_policies" {
  for_each = local.account_roles
  
  role       = aws_iam_role.account_roles[each.key].name
  policy_arn = each.value.managed_policies[0]
}

# Create instance profiles for EC2 roles with OpenShift version
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
}
