# rosa-sts-manual.tf

# First, get the policies from RHCS provider (this auto-discovers Red Hat account IDs)
data "rhcs_policies" "account_role_policies" {}

data "rhcs_rosa_oidc_config" "existing_oidc" {
  count = var.oidc_config_id != "" ? 1 : 0
  id    = var.oidc_config_id
}

# Generate external ID for additional security
resource "random_uuid" "external_id" {}

# 1. OCM Role - Auto-discovered trust relationship
data "aws_iam_policy_document" "ocm_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    
    principals {
      type = "AWS"
      # This gets the Red Hat AWS account from the policies data source
      identifiers = data.rhcs_policies.account_role_policies.account_role_policies["ManagedOpenShift-OCM-Role"].assume_role_policy_document
    }
    
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [random_uuid.external_id.result]
    }
  }
}

resource "aws_iam_role" "ocm_role" {
  name = "${var.prefix}-OCM-Role"
  path = "/"
  
  assume_role_policy = data.aws_iam_policy_document.ocm_assume_role.json
  
  tags = merge(local.common_tags, {
    Name = "${var.prefix}-OCM-Role"
    Type = "OCM"
  })
}

# Attach managed policies to OCM role
resource "aws_iam_role_policy_attachment" "ocm_role_policy" {
  role       = aws_iam_role.ocm_role.name
  policy_arn = "arn:${local.partition}:iam::aws:policy/service-role/ROSAOCMRole"
}

# 2. User Role - Auto-discovered trust relationship
data "aws_iam_policy_document" "user_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    
    principals {
      type = "AWS"
      # This gets the Red Hat AWS account from the policies data source
      identifiers = data.rhcs_policies.account_role_policies.account_role_policies["ManagedOpenShift-User-Role"].assume_role_policy_document
    }
  }
}

resource "aws_iam_role" "user_role" {
  name = "${var.prefix}-User-Role"
  path = "/"
  
  assume_role_policy = data.aws_iam_policy_document.user_assume_role.json
  
  tags = merge(local.common_tags, {
    Name = "${var.prefix}-User-Role"
    Type = "User"
  })
}

resource "aws_iam_role_policy_attachment" "user_role_policy" {
  role       = aws_iam_role.user_role.name
  policy_arn = "arn:${local.partition}:iam::aws:policy/service-role/ROSAUserRole"
}

# 3. Account Roles (Installer, Support, Worker, Control Plane)
locals {
  account_roles = [
    {
      name        = "Installer-Role"
      policy_arn  = "arn:${local.partition}:iam::aws:policy/service-role/ROSAInstallerRole"
      max_session = "1h"
    },
    {
      name        = "Support-Role" 
      policy_arn  = "arn:${local.partition}:iam::aws:policy/service-role/ROSASupportRole"
      max_session = "1h"
    },
    {
      name        = "ControlPlane-Role"
      policy_arn  = "arn:${local.partition}:iam::aws:policy/service-role/ROSAControlPlaneRole"
      max_session = "1h"
    },
    {
      name        = "Worker-Role"
      policy_arn  = "arn:${local.partition}:iam::aws:policy/service-role/ROSAWorkerInstanceRole"
      max_session = "1h"
    }
  ]
}

# Account roles trust relationships (auto-discovered)
data "aws_iam_policy_document" "account_role_assume_role" {
  for_each = { for role in local.account_roles : role.name => role }
  
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    
    principals {
      type = "AWS"
      # Gets Red Hat account from policies data source
      identifiers = data.rhcs_policies.account_role_policies.account_role_policies["ManagedOpenShift-${each.value.name}"].assume_role_policy_document
    }
  }
}

resource "aws_iam_role" "account_roles" {
  for_each = { for role in local.account_roles : role.name => role }
  
  name = "${var.prefix}-${each.value.name}"
  path = "/"
  
  assume_role_policy    = data.aws_iam_policy_document.account_role_assume_role[each.key].json
  max_session_duration = each.value.max_session == "1h" ? 3600 : 43200
  
  tags = merge(local.common_tags, {
    Name = "${var.prefix}-${each.value.name}"
    Type = "Account"
  })
}

resource "aws_iam_role_policy_attachment" "account_role_policies" {
  for_each = { for role in local.account_roles : role.name => role }
  
  role       = aws_iam_role.account_roles[each.key].name
  policy_arn = each.value.policy_arn
}
