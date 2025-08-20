# operator-roles.tf - Operator roles (optional, for full cluster setup)

# Example operator roles - you may need to adjust based on your cluster needs
locals {
  operator_roles = {
    "cloud-credentials" = {
      name      = "cloud-credentials"
      namespace = "openshift-cloud-credential-operator"
      policies  = ["CloudCredentialOperatorRole"]
    }
    "image-registry" = {
      name      = "image-registry"
      namespace = "openshift-image-registry"
      policies  = ["ImageRegistryOperatorRole"]
    }
    "ingress" = {
      name      = "ingress"
      namespace = "openshift-ingress-operator"
      policies  = ["IngressOperatorRole"]
    }
    "cluster-csi-drivers" = {
      name      = "cluster-csi-drivers"
      namespace = "openshift-cluster-csi-drivers"
      policies  = ["CSIDriverOperatorRole"]
    }
  }
}

# Trust policy for operator roles
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
      variable = "${replace(aws_iam_openid_connect_provider.rosa_oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${each.value.namespace}:${each.value.name}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.rosa_oidc.url, "https://", "")}:aud"
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

# Attach policies to operator roles (you'll need to create/reference appropriate policies)
resource "aws_iam_role_policy_attachment" "operator_policy_attachments" {
  for_each = {
    for combo in flatten([
      for role_key, role in local.operator_roles : [
        for policy in role.policies : {
          role_key   = role_key
          policy     = policy
          combo_key  = "${role_key}-${policy}"
        }
      ]
    ]) : combo.combo_key => combo
  }
  
  role       = aws_iam_role.operator_roles[each.value.role_key].name
  policy_arn = "arn:${local.partition}:iam::aws:policy/service-role/ROSA${each.value.policy}"
  
  # Note: You may need to create custom policies or use different ARNs based on actual ROSA operator policies
}
