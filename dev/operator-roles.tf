# operator-roles.tf - Updated with proper OIDC URL handling

# Example operator roles with fixed OIDC references
locals {
  operator_roles = {
    "cloud-credentials" = {
      name      = "cloud-credentials"
      namespace = "openshift-cloud-credential-operator"
      policies  = ["ROSACloudCredentialsRole"]
    }
    "image-registry" = {
      name      = "image-registry"
      namespace = "openshift-image-registry"
      policies  = ["ROSAImageRegistryRole"]
    }
    "ingress" = {
      name      = "ingress"
      namespace = "openshift-ingress-operator"
      policies  = ["ROSAIngressRole"]
    }
    "cluster-csi-drivers" = {
      name      = "cluster-csi-drivers"
      namespace = "openshift-cluster-csi-drivers"
      policies  = ["ROSANodePoolManagementRole"]
    }
  }
  
  # Extract hostname from OIDC URL for conditions
  oidc_hostname = replace(aws_iam_openid_connect_provider.rosa_oidc.url, "https://", "")
}

# Trust policy for operator roles with fixed OIDC reference
data "aws_iam_policy_document" "operator_trust_policy" {
  for_each = local.operator_roles
  
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.rosa_oidc.arn]
    }
    
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_hostname}:sub"
      values   = ["system:serviceaccount:${each.value.namespace}:${each.value.name}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_hostname}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# Create operator roles
resource "aws_iam_role" "operator_roles" {
  for_each = local.operator_roles
  
  name = "${var.prefix}-${replace(each.key, "-", "_")}-operator-role"
  path = var.path
  
  assume_role_policy   = data.aws_iam_policy_document.operator_trust_policy[each.key].json
  max_session_duration = 3600
  
  tags = merge(local.common_tags, {
    Name      = "${var.prefix}-${each.key}-operator-role"
    Type      = "OperatorRole"
    Operator  = each.key
    Namespace = each.value.namespace
  })
}

# Custom policies for operator roles (since AWS managed policies may not exist)
data "aws_iam_policy_document" "cloud_credentials_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
      "sts:GetAccessKeyInfo",
    ]
    resources = ["*"]
  }
  
  statement {
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:ListRoles",
      "iam:PassRole",
    ]
    resources = [
      "arn:${local.partition}:iam::${local.account_id}:role/${var.prefix}-*"
    ]
  }
}

data "aws_iam_policy_document" "image_registry_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:PutBucketTagging",
      "s3:GetBucketTagging",
      "s3:PutBucketPublicAccessBlock",
      "s3:GetBucketPublicAccessBlock",
      "s3:PutEncryptionConfiguration",
      "s3:GetEncryptionConfiguration",
      "s3:PutBucketPolicy",
      "s3:GetBucketPolicy",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "arn:${local.partition}:s3:::*"
    ]
  }
}

# Apply custom policies
resource "aws_iam_role_policy" "operator_policies" {
  for_each = local.operator_roles
  
  name = "${var.prefix}-${each.key}-operator-policy"
  role = aws_iam_role.operator_roles[each.key].id
  
  policy = each.key == "cloud-credentials" ? data.aws_iam_policy_document.cloud_credentials_policy.json : (
    each.key == "image-registry" ? data.aws_iam_policy_document.image_registry_policy.json : 
    jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "sts:GetCallerIdentity"
          ]
          Resource = "*"
        }
      ]
    })
  )
}
