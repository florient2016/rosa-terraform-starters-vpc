# rosa-prerequisites.tf - ROSA prerequisites

# Create account roles using ROSA CLI
resource "null_resource" "create_account_roles" {
  provisioner "local-exec" {
    command = <<-EOT
      echo "🔍 Checking existing account roles..."
      
      # Check if roles already exist
      if rosa list account-roles --prefix ${var.prefix} | grep -q "${var.prefix}-ManagedOpenShift"; then
        echo "✅ Account roles with prefix '${var.prefix}' already exist"
        rosa list account-roles --prefix ${var.prefix}
      else
        echo "🔄 Creating account roles with prefix '${var.prefix}'..."
        
        # Create account roles with version compatibility
        rosa create account-roles \
          --mode auto \
          --yes \
          --prefix "${var.prefix}" \
          --version "${var.openshift_version}" \
          --force-policy-creation
        
        echo "✅ Account roles created successfully"
        rosa list account-roles --prefix ${var.prefix}
      fi
    EOT
  }
  
  # Trigger recreation if version changes
  triggers = {
    prefix            = var.prefix
    openshift_version = var.openshift_version
  }
}

# Wait for account roles to be ready
resource "time_sleep" "wait_for_account_roles" {
  depends_on = [null_resource.create_account_roles]
  
  create_duration = "30s"
}

# Verify account roles exist
resource "null_resource" "verify_account_roles" {
  depends_on = [time_sleep.wait_for_account_roles]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🔍 Verifying account roles..."
      
      # List all account roles
      rosa list account-roles --prefix ${var.prefix}
      
      # Verify specific roles exist
      roles=("${var.prefix}-ManagedOpenShift-Installer-Role" "${var.prefix}-ManagedOpenShift-Support-Role" "${var.prefix}-ManagedOpenShift-ControlPlane-Role" "${var.prefix}-ManagedOpenShift-Worker-Role")
      
      for role in "$${roles[@]}"; do
        if aws iam get-role --role-name "$role" &>/dev/null; then
          echo "✅ Role $role exists"
        else
          echo "❌ Role $role does not exist"
          exit 1
        fi
      done
      
      echo "✅ All account roles verified successfully"
    EOT
  }
  
  triggers = {
    account_roles = null_resource.create_account_roles.id
  }
}
