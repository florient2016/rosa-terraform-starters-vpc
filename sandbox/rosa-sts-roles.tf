# rosa-sts-roles.tf - Complete working implementation

# 1. Account Roles using RHCS data and AWS resources
locals {
  account_role_policies = {
    installer = {
      name         = "ManagedOpenShift-Installer-Role"
      aws_managed = "ROSAInstallerRole"
    }
    support = {
      name         = "ManagedOpenShift-Support-Role"
      aws_managed  = "ROSASupportRole"
    }
    controlplane = {
      name         = "ManagedOpenShift-ControlPlane-Role"
      aws_managed  = "ROSAControlPlaneRole"
    }
    worker = {
      name         = "ManagedOpenShift-Worker-Role"
      aws_managed  = "ROSAWorkerRole"
    }
  }
}

# Trust policy for account roles
data "aws_iam_policy_document" "account_role_trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    
    principals {
      type        = "AWS"
      identifiers = ["arn:${local.partition}:iam::${local.red_hat_aws_account}:root"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }
  }
}

# Create account roles
resource "aws_iam_role" "account_roles" {
  for_each = local.account_role_policies
  
  name = "${var.prefix}-${each.value.name}"
  path = var.path
  
  assume_role_policy   = data.aws_iam_policy_document.account_role_trust_policy.json
  max_session_duration = 3600
  
  tags = merge(local.common_tags, {
    Name = "${var.prefix}-${each.value.name}"
    Type = "AccountRole"
    Role = each.key
  })
}

# Attach AWS managed policies to account roles
resource "aws_iam_role_policy_attachment" "account_role_policies" {
  for_each = local.account_role_policies
  
  role       = aws_iam_role.account_roles[each.key].name
  policy_arn = "arn:${local.partition}:iam::aws:policy/service-role/${each.value.aws_managed}"
}

# 2. OCM Role
data "aws_iam_policy_document" "ocm_trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    
    principals {
      type        = "AWS"
      identifiers = ["arn:${local.partition}:iam::${local.red_hat_aws_account}:root"]
    }
  }
}

resource "aws_iam_role" "ocm_role" {
  name = "${var.prefix}-ManagedOpenShift-OCM-Role"
  path = var.path
  
  assume_role_policy   = data.aws_iam_policy_document.ocm_trust_policy.json
  max_session_duration = 3600
  
  tags = merge(local.common_tags, {
    Name = "${var.prefix}-ManagedOpenShift-OCM-Role"
    Type = "OCMRole"
  })
}

# OCM Role inline policy
data "aws_iam_policy_document" "ocm_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      aws_iam_role.account_roles["installer"].arn,
      aws_iam_role.account_roles["support"].arn,
      aws_iam_role.account_roles["controlplane"].arn,
      aws_iam_role.account_roles["worker"].arn
    ]
  }
  
  statement {
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:ListRoles",
      "iam:GetOpenIDConnectProvider",
      "iam:ListOpenIDConnectProviders"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ocm_policy" {
  name   = "${var.prefix}-OCMRolePolicy"
  role   = aws_iam_role.ocm_role.id
  policy = data.aws_iam_policy_document.ocm_policy.json
}

# 3. User Role
resource "aws_iam_role" "user_role" {
  name = "${var.prefix}-ManagedOpenShift-User-Role"
  path = var.path
  
  assume_role_policy   = data.aws_iam_policy_document.ocm_trust_policy.json
  max_session_duration = 3600
  
  tags = merge(local.common_tags, {
    Name = "${var.prefix}-ManagedOpenShift-User-Role"
    Type = "UserRole"
  })
}

# User Role inline policy
data "aws_iam_policy_document" "user_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      aws_iam_role.account_roles["support"].arn
    ]
  }
}

resource "aws_iam_role_policy" "user_policy" {
  name   = "${var.prefix}-UserRolePolicy"
  role   = aws_iam_role.user_role.id
  policy = data.aws_iam_policy_document.user_policy.json
}
