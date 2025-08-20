# oidc.tf - Fixed OIDC Configuration

# Create OIDC configuration
resource "rhcs_rosa_oidc_config" "oidc_config" {
  managed = true
}

# Create OIDC provider in AWS with proper URL formatting
resource "aws_iam_openid_connect_provider" "rosa_oidc" {
  # Fix the URL by adding https:// protocol
  url = "https://${rhcs_rosa_oidc_config.oidc_config.oidc_endpoint_url}"
  
  client_id_list = [
    "openshift",
    "sts.amazonaws.com"
  ]
  
  thumbprint_list = [rhcs_rosa_oidc_config.oidc_config.thumbprint]
  
  tags = merge(local.common_tags, {
    Name = "${var.prefix}-rosa-oidc-provider"
    Type = "OIDCProvider"
  })
  
  lifecycle {
    ignore_changes = [thumbprint_list]
  }
}

# Optional: Data source to validate the OIDC configuration
#data "aws_iam_openid_connect_provider" "rosa_oidc_validation" {
#  url = aws_iam_openid_connect_provider.rosa_oidc.url
#  
#  depends_on = [aws_iam_openid_connect_provider.rosa_oidc]
#}
