# oidc.tf - OIDC Configuration using RHCS provider

# Create OIDC configuration
resource "rhcs_rosa_oidc_config" "oidc_config" {
  managed = true
}

# Create OIDC provider in AWS
resource "aws_iam_openid_connect_provider" "rosa_oidc" {
  url = rhcs_rosa_oidc_config.oidc_config.oidc_endpoint_url
  
  client_id_list = [
    "openshift",
    "sts.amazonaws.com"
  ]
  
  thumbprint_list = [rhcs_rosa_oidc_config.oidc_config.thumbprint]
  
  tags = merge(local.common_tags, {
    Name = "${var.prefix}-rosa-oidc-provider"
  })
  
  lifecycle {
    ignore_changes = [thumbprint_list]
  }
}
