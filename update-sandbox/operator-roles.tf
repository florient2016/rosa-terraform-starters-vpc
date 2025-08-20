# operator-roles.tf - Create ROSA operator roles

# Create operator roles using ROSA CLI
resource "null_resource" "create_operator_roles" {
  depends_on = [
    time_sleep.wait_for_oidc,
    null_resource.verify_account_roles
  ]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🔍 Checking existing operator roles..."
      
      # Check if operator roles already exist
      if rosa list operator-roles --prefix ${var.prefix} | grep -q "${var.prefix}-"; then
        echo "✅ Operator roles with prefix '${var.prefix}' already exist"
        rosa list operator-roles --prefix ${var.prefix}
      else
        echo "🔄 Creating operator roles with prefix '${var.prefix}'..."
        
        # Create operator roles
        rosa create operator-roles \
          --mode auto \
          --yes \
          --prefix "${var.prefix}" \
          --oidc-config-id "${rhcs_rosa_oidc_config.oidc_config.id}" \
          --installer-role-arn "${local.installer_role_arn}"
        
        echo "✅ Operator roles created successfully"
        rosa list operator-roles --prefix ${var.prefix}
      fi
    EOT
  }
  
  triggers = {
    oidc_config_id = rhcs_rosa_oidc_config.oidc_config.id
    prefix         = var.prefix
  }
}

# Wait for operator roles to be ready
resource "time_sleep" "wait_for_operator_roles" {
  depends_on = [null_resource.create_operator_roles]
  
  create_duration = "30s"
}

# Verify operator roles
resource "null_resource" "verify_operator_roles" {
  depends_on = [time_sleep.wait_for_operator_roles]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🔍 Verifying operator roles..."
      rosa list operator-roles --prefix ${var.prefix}
      echo "✅ Operator roles verification completed"
    EOT
  }
  
  triggers = {
    operator_roles = null_resource.create_operator_roles.id
  }
}
