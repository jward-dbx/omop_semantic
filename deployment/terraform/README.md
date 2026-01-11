# Terraform Configuration

This directory contains Terraform configurations for managing Databricks infrastructure.

## Purpose

Use Terraform to define and manage:
- Unity Catalog catalogs and schemas
- Workspace resources
- Permissions and access controls
- Service principals
- Clusters and compute resources

## Structure

```
terraform/
├── main.tf           # Main configuration
├── variables.tf      # Variable definitions
├── outputs.tf        # Output values
├── providers.tf      # Provider configuration
├── catalogs/         # Catalog definitions
├── schemas/          # Schema definitions
└── permissions/      # Access control configs
```

## Usage

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply

# Destroy resources (careful!)
terraform destroy
```

## Best Practices

1. Use variables for environment-specific values
2. Store state remotely (e.g., S3, Azure Blob)
3. Use workspaces for dev/prod separation
4. Always run `plan` before `apply`
5. Document resource dependencies

---

*Terraform configurations will be added as needed*
