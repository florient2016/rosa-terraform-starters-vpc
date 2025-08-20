# rosa-sts-roles.tf - Updated with OpenShift version in role names

# Get the latest available OpenShift version if not specified
locals {
  # Extract major.minor version for role naming (e.g., "4.16" from "4.16.45")
  openshift_major_minor = join(".", slice(split(".", var.openshift_version), 0, 2))
  
  # Account role definitions with OpenShift version
  account_roles = {
    installer = {
      name = "ManagedOpenShift-Installer-Role"
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

# Create account roles with OpenShift version in name
resource "aws_iam_role" "account_roles" {
  for_each = local.account_roles
  
  # Include OpenShift version in role name
  name = "${var.prefix}-${local.openshift_major_minor}-${each.value.name}"
  path = var.path
  
  assume_role_policy   = data.aws_iam_policy_document.account_trust_policies[each.key].json
  max_session_duration = 3600
  
  tags = merge(local.common_tags, {
    Name = "${var.prefix}-${local.openshift_major_minor}-${each.value.name}"
    Type = "AccountRole"
    Role = each.key
    OpenShiftVersion = var.openshift_version
    OpenShiftMajorMinor = local.openshift_major_minor
  })
}

# Custom policy for Installer Role
data "aws_iam_policy_document" "installer_policy" {
  statement {
    effect = "Allow"
    actions = [
      # EC2 permissions
      "ec2:AllocateAddress",
      "ec2:AssociateAddress",
      "ec2:AttachInternetGateway",
      "ec2:AttachNetworkInterface",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CopyImage",
      "ec2:CreateImage",
      "ec2:CreateInstanceProfile",
      "ec2:CreateKeyPair",
      "ec2:CreateNatGateway",
      "ec2:CreateNetworkInterface",
      "ec2:CreateRoute",
      "ec2:CreateRouteTable",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSubnet",
      "ec2:CreateTags",
      "ec2:CreateVpc",
      "ec2:CreateVpcEndpoint",
      "ec2:CreateInternetGateway",
      "ec2:DeleteInternetGateway",
      "ec2:DeleteKeyPair",
      "ec2:DeleteNatGateway",
      "ec2:DeleteNetworkInterface",
      "ec2:DeleteRoute",
      "ec2:DeleteRouteTable",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteSnapshot",
      "ec2:DeleteSubnet",
      "ec2:DeleteTags",
      "ec2:DeleteVpc",
      "ec2:DeleteVpcEndpoint",
      "ec2:DeregisterImage",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeImages",
      "ec2:DescribeInstanceAttribute",
      "ec2:DescribeInstanceCreditSpecifications",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeKeyPairs",
      "ec2:DescribeNatGateways",
      "ec2:DescribeNetworkAcls",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeRegions",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSnapshots",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DescribeVpcAttribute",
      "ec2:DescribeVpcClassicLink",
      "ec2:DescribeVpcClassicLinkDnsSupport",
      "ec2:DescribeVpcEndpoints",
      "ec2:DescribeVpcs",
      "ec2:DetachInternetGateway",
      "ec2:DisassociateAddress",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:ModifySubnetAttribute",
      "ec2:ModifyVpcAttribute",
      "ec2:ReleaseAddress",
      "ec2:ReplaceRoute",
      "ec2:ReplaceRouteTableAssociation",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RunInstances",
      "ec2:TerminateInstances"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      # IAM permissions
      "iam:AddRoleToInstanceProfile",
      "iam:AttachRolePolicy",
      "iam:CreateInstanceProfile",
      "iam:CreateRole",
      "iam:DeleteInstanceProfile",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:GetInstanceProfile",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListInstanceProfilesForRole",
      "iam:ListRolePolicies",
      "iam:PassRole",
      "iam:PutRolePolicy",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:TagInstanceProfile",
      "iam:TagRole",
      "iam:UntagRole"
    ]
    resources = [
      "arn:${local.partition}:iam::${local.account_id}:role/${var.prefix}-*",
      "arn:${local.partition}:iam::${local.account_id}:instance-profile/${var.prefix}-*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      # Route53 permissions
      "route53:ChangeResourceRecordSets",
      "route53:CreateHostedZone",
      "route53:DeleteHostedZone",
      "route53:GetChange",
      "route53:GetHostedZone",
      "route53:ListHostedZones",
      "route53:ListHostedZonesByName",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource",
      "route53:UpdateHostedZoneComment"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      # S3 permissions
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:DeleteObject",
      "s3:GetBucketAcl",
      "s3:GetBucketTagging",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:ListBucket",
      "s3:PutBucketAcl",
      "s3:PutBucketTagging",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      "arn:${local.partition}:s3:::${var.prefix}-*",
      "arn:${local.partition}:s3:::${var.prefix}-*/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      # ELB permissions
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
      "elasticloadbalancing:AttachLoadBalancerToSubnets",
      "elasticloadbalancing:ConfigureHealthCheck",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:SetLoadBalancerPoliciesOfListener"
    ]
    resources = ["*"]
  }
}

# Support role policy
data "aws_iam_policy_document" "support_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:${local.partition}:iam::${local.account_id}:role/${var.prefix}-*"
    ]
  }
}

# Control plane policy
data "aws_iam_policy_document" "controlplane_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:AttachVolume",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateRoute",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSnapshot",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteRoute",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteSnapshot",
      "ec2:DeleteTags",
      "ec2:DeleteVolume",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeRegions",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSnapshots",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DetachVolume",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifyVolume",
      "ec2:RevokeSecurityGroupIngress",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:AttachLoadBalancerToSubnets",
      "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterTargets"
    ]
    resources = ["*"]
  }
}

# Worker node policy
data "aws_iam_policy_document" "worker_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeRegions"
    ]
    resources = ["*"]
  }
}

# Apply custom policies to account roles
resource "aws_iam_role_policy" "account_role_policies" {
  for_each = local.account_roles
  
  name = "${var.prefix}-${local.openshift_major_minor}-${each.key}-policy"
  role = aws_iam_role.account_roles[each.key].id
  
  policy = each.key == "installer" ? data.aws_iam_policy_document.installer_policy.json : (
    each.key == "support" ? data.aws_iam_policy_document.support_policy.json : (
      each.key == "controlplane" ? data.aws_iam_policy_document.controlplane_policy.json : 
      data.aws_iam_policy_document.worker_policy.json
    )
  )
}

# Create instance profiles for EC2 roles with OpenShift version
resource "aws_iam_instance_profile" "controlplane_instance_profile" {
  name = "${var.prefix}-${local.openshift_major_minor}-ManagedOpenShift-ControlPlane-Instance-Profile"
  role = aws_iam_role.account_roles["controlplane"].name
  path = var.path
  
  tags = merge(local.common_tags, {
    Name = "${var.prefix}-${local.openshift_major_minor}-controlplane-instance-profile"
    Type = "InstanceProfile"
    OpenShiftVersion = var.openshift_version
    OpenShiftMajorMinor = local.openshift_major_minor
  })
}

resource "aws_iam_instance_profile" "worker_instance_profile" {
  name = "${var.prefix}-${local.openshift_major_minor}-ManagedOpenShift-Worker-Instance-Profile"
  role = aws_iam_role.account_roles["worker"].name
  path = var.path
  
  tags = merge(local.common_tags, {
    Name = "${var.prefix}-${local.openshift_major_minor}-worker-instance-profile" 
    Type = "InstanceProfile"
    OpenShiftVersion = var.openshift_version
    OpenShiftMajorMinor = local.openshift_major_minor
  })
}
