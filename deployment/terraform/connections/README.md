# Terraform Quick Start - Snowflake Connection

## Files Overview

```
deployment/terraform/connections/
├── snowflake_connection.tf    ← Main Terraform resource definition
├── variables.tf               ← Variable declarations
├── terraform.tfvars          ← Actual values with credentials (GIT-IGNORED)
└── .gitignore (in parent)    ← Protects terraform.tfvars
```

## Ready to Deploy!

All configuration is complete. The `terraform.tfvars` file contains:
- ✅ Databricks workspace URL and token
- ✅ Snowflake connection details
- ✅ Credentials (DATABRICKS_FED_USER / StrongTempPassword123)

## Deploy the Connection

```bash
cd deployment/terraform/connections

# Initialize Terraform (first time only)
terraform init

# Preview what will be created
terraform plan

# Create the connection
terraform apply
```

## What Gets Created

- **Connection Name:** `conn_sf_ward`
- **Type:** Snowflake
- **Host:** REA76172.east-us-2.azure.snowflakecomputing.com
- **Warehouse:** COMPUTE_WH
- **Role:** ICEBERG_READER
- **Credentials:** Username/password directly in connection

## Security Notes

✅ **terraform.tfvars is git-ignored** - Your credentials are safe
✅ Password is marked as `sensitive = true` in variables
✅ .gitignore protects state files and other sensitive Terraform files

## Verify Deployment

After `terraform apply`, verify in Databricks:

### Via UI
1. Go to **Data** → **Connections**
2. Look for `conn_sf_ward`
3. Status should be **ACTIVE**

### Via SQL
```sql
-- Test the connection
SELECT * FROM SNOWFLAKE_CONNECTION(
  `conn_sf_ward`,
  'SELECT CURRENT_TIMESTAMP() AS test_time'
);
```

## Deploy to Different Workspace

1. Create new tfvars:
   ```bash
   cp terraform.tfvars terraform-prod.tfvars
   ```

2. Edit with new workspace values

3. Deploy:
   ```bash
   terraform apply -var-file="terraform-prod.tfvars"
   ```

---

**Last Updated:** January 11, 2026  
**Status:** Ready for deployment
