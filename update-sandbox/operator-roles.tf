# rosa-operator-roles.tf - HCP Operator Roles

locals {
  operator_roles = {
    "openshift-ingress-operator" = {
      namespace = "openshift-ingress-operator"
      service_account = "ingress-operator"
    }
    "openshift-cluster-csi-drivers" = {
      namespace = "openshift-cluster-csi-drivers" 
      service_account = "aws-ebs-csi-driver-operator"
    }
    "openshift-cloud-network-config-controller" = {
      namespace = "openshift-cloud-network-config-controller"
      service_account = "cloud-network-config-controller"
    }
    "openshift-machine-api" = {
      namespace = "openshift-machine-api"
      service_account = "machine-api-controllers"
    }
    "openshift-cloud-credential-operator" = {
      namespace = "openshift-cloud-credential-operator"
      service_account = "cloud-credential-operator"
    }
    "openshift-image-registry" = {
      namespace = "openshift-image-registry"
      service_account = "cluster-image-registry-operator"
    }
  }
  
  cluster_name = var.cluster_name != "" ? var.cluster_name : "my-cluster"
  oidc_endpoint_url = "https://rh-oidc.s3.us-east-1.amazonaws.com/${random_string.oidc_config_id.result}"
}

# Generate random string for OIDC config
resource "random_string" "oidc_config_id" {
  length  = 27
  special = false
  upper   = false
}

# OIDC Provider for the cluster
resource "aws_iam_openid_connect_provider" "cluster_oidc" {
  url = local.oidc_endpoint_url

  client_id_list = [
    "openshift",
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "917e732d330f9a12404f73d8bea36948b929dffc",
    "a9d53002e97e00e043244f3d170d6f4c414104fd"
  ]

  tags = merge(var.tags, {
    "rosa:cluster_name" = local.cluster_name
    "rosa:cluster_type" = "hcp"
  })
}

# Get policy documents for operator roles
data "aws_iam_policy_document" "operator_role_trust_policy" {
  for_each = local.operator_roles

  statement {
    effect = "Allow"
    
    principals {
      type = "Federated"
      identifiers = [aws_iam_openid_connect_provider.cluster_oidc.arn]
    }
    
    actions = ["sts:AssumeRoleWithWebIdentity"]
    
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.cluster_oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${each.value.namespace}:${each.value.service_account}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.cluster_oidc.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# Operator IAM Roles
resource "aws_iam_role" "operator_roles" {
  for_each = local.operator_roles

  name = "${var.prefix}-${local.cluster_name}-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.operator_role_trust_policy[each.key].json
  
  tags = merge(var.tags, {
    "rosa:cluster_name" = local.cluster_name
    "rosa:cluster_type" = "hcp"
    "rosa:operator_namespace" = each.value.namespace
    "rosa:operator_name" = each.key
  })
}

# Attach AWS managed policies to operator roles
resource "aws_iam_role_policy_attachment" "operator_role_policies" {
  for_each = {
    "openshift-ingress-operator" = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
    "openshift-cluster-csi-drivers" = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    "openshift-cloud-network-config-controller" = "arn:aws:iam::aws:policy/EC2FullAccess"
    "openshift-machine-api" = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
    "openshift-cloud-credential-operator" = "arn:aws:iam::aws:policy/IAMFullAccess"
    "openshift-image-registry" = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  }

  role       = aws_iam_role.operator_roles[each.key].name
  policy_arn = each.value
}
