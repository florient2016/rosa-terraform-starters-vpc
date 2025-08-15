# ROSA Terraform Starters with Optional VPC (HCP & Classic)

This package adds an **optional VPC module** so you can either:
- Use an **existing VPC / subnets** (provide `existing_subnet_ids`), or
- **Create a new VPC** via `terraform-aws-modules/vpc/aws` by setting `create_vpc = true`.

**Important:** This starter **does not** provision any IdP (htpasswd or GitHub) — you requested those removed.

## How to use
- Ensure Terraform >= 1.4.6, AWS CLI configured, and `RHCS_TOKEN` exported.
- Edit `terraform.tfvars` for each stack to choose between existing subnets or create a VPC.

Run:
```bash
# HCP
cd hcp
export RHCS_TOKEN="sha256~your_offline_ocm_token"
terraform init
terraform apply -var-file=terraform.tfvars

# Classic
cd ../classic
export RHCS_TOKEN="sha256~your_offline_ocm_token"
terraform init
terraform apply -var-file=terraform.tfvars
```

Then run `terraform output -json | jq` to verify the many outputs (cluster IDs, console/API URLs, role ARNs, OIDC issuer, VPC and subnet ids).

