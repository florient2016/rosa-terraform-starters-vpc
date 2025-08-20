# rosa-sts-manual.tf - Manual IAM Implementation

# Generate external ID for security
resource "random_uuid" "external_id" {}

# Red Hat's AWS accounts (these are the official ones)
locals {
  # These are Red Hat's official AWS account IDs for ROSA
  red_hat_aws_account = "710019948333"  # This is the correct Red Hat account ID
}

# 1. OCM Role
data "aws_iam_policy_document" "ocm_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    
    principals {
      type        = "AWS"
      identifiers = ["arn:${local.partition}:iam::${local.red_hat_aws_account}:root"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [random_uuid.external_id.result]
    }
  }
}

resource "aws_iam_role" "ocm_role" {
  name = "${var.prefix}-ManagedOpenShift-OCM-Role"
  path = "/"
  
  assume_role_policy    = data.aws_iam_policy_document.ocm_assume_role_policy.json
  max_session_duration  = 3600
  
  tags = merge(local.common_tags, {
    Name = "${var.prefix}-ManagedOpenShift-OCM-Role"
    Type = "OCM"
  })
}

# OCM Role Policy
data "aws_iam_policy_document" "ocm_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:${local.partition}:iam::${local.account_id}:role/${var.prefix}-ManagedOpenShift-Installer-Role",
      "arn:${local.partition}:iam::${local.account_id}:role/${var.prefix}-ManagedOpenShift-Support-Role"
    ]
  }
  
  statement {
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:ListRoles"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ocm_policy" {
  name   = "${var.prefix}-OCMRolePolicy"
  role   = aws_iam_role.ocm_role.id
  policy = data.aws_iam_policy_document.ocm_policy.json
}

# 2. User Role
data "aws_iam_policy_document" "user_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    
    principals {
      type        = "AWS"
      identifiers = ["arn:${local.partition}:iam::${local.red_hat_aws_account}:root"]
    }
  }
}

resource "aws_iam_role" "user_role" {
  name = "${var.prefix}-ManagedOpenShift-User-Role"
  path = "/"
  
  assume_role_policy    = data.aws_iam_policy_document.user_assume_role_policy.json
  max_session_duration  = 3600
  
  tags = merge(local.common_tags, {
    Name = "${var.prefix}-ManagedOpenShift-User-Role"
    Type = "User"
  })
}

# User Role Policy
data "aws_iam_policy_document" "user_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:${local.partition}:iam::${local.account_id}:role/${var.prefix}-ManagedOpenShift-Support-Role"
    ]
  }
}

resource "aws_iam_role_policy" "user_policy" {
  name   = "${var.prefix}-UserRolePolicy"
  role   = aws_iam_role.user_role.id
  policy = data.aws_iam_policy_document.user_policy.json
}

# 3. Account Roles
locals {
  account_roles = {
    installer = {
      name = "ManagedOpenShift-Installer-Role"
      policies = [
        "arn:${local.partition}:iam::aws:policy/service-role/ROSAInstallerRole"
      ]
    }
    support = {
      name = "ManagedOpenShift-Support-Role" 
      policies = [
        "arn:${local.partition}:iam::aws:policy/service-role/ROSASupportRole"
      ]
    }
    controlplane = {
      name = "ManagedOpenShift-ControlPlane-Role"
      policies = [
        "arn:${local.partition}:iam::aws:policy/service-role/ROSAControlPlaneRole"
      ]
    }
    worker = {
      name = "ManagedOpenShift-Worker-Role"
      policies = [
        "arn:${local.partition}:iam::aws:policy/service-role/ROSAWorkerRole"
      ]
    }
  }
}

data "aws_iam_policy_document" "account_role_assume_policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    
    principals {
      type        = "AWS"
      identifiers = ["arn:${local.partition}:iam::${local.red_hat_aws_account}:root"]
    }
  }
}

resource "aws_iam_role" "account_roles" {
  for_each = local.account_roles
  
  name = "${var.prefix}-${each.value.name}"
  path = "/"
  
  assume_role_policy    = data.aws_iam_policy_document.account_role_assume_policy.json
  max_session_duration  = 3600
  
  tags = merge(local.common_tags, {
    Name = "${var.prefix}-${each.value.name}"
    Type = "Account"
  })
}

resource "aws_iam_role_policy_attachment" "account_role_policies" {
  for_each = {
    for combo in flatten([
      for role_key, role in local.account_roles : [
        for policy_arn in role.policies : {
          role_key    = role_key
          policy_arn  = policy_arn
          attachment_key = "${role_key}-${basename(policy_arn)}"
        }
      ]
    ]) : combo.attachment_key => combo
  }
  
  role       = aws_iam_role.account_roles[each.value.role_key].name
  policy_arn = each.value.policy_arn
}

# 4. OIDC Configuration (using AWS resources)
resource "aws_iam_openid_connect_provider" "rosa_oidc" {
  url = "https://rh-oidc.s3.us-east-1.amazonaws.com/${random_uuid.external_id.result}"
  
  client_id_list = [
    "openshift",
    "sts.amazonaws.com"
  ]
  
  thumbprint_list = [
    "a9d53002e97e00e043244f3d170d6f4c414104fd",  # Red Hat OIDC thumbprint
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"   # AWS root CA thumbprint
  ]
  
  tags = local.common_tags
}
