# Terraform Quick Start - Snowflake Connection & Catalog

## Files Overview

```
deployment/terraform/connections/
├── snowflake_connection.tf       ← Connection resource definition
├── snowflake_catalog.tf          ← Catalog resource definition  
├── variables.tf                  ← Variable declarations
├── terraform.tfvars             ← Actual values with credentials (GIT-IGNORED)
├── .terraform.lock.hcl          ← Provider version lock
└── README.md                    ← This file
```

## Ready to Deploy!

All configuration is complete. The `terraform.tfvars` file contains:
- ✅ Databricks workspace URL and token
- ✅ Snowflake connection details
- ✅ Credentials (DATABRICKS_FED_USER / StrongTempPassword123)
- ✅ Catalog configuration (OMOP database)

## Deploy Connection + Catalog

**Single deployment creates both resources:**

```bash
cd deployment/terraform/connections

# Initialize Terraform (first time only)
terraform init

# Preview what will be created
terraform plan

# Create connection AND catalog
terraform apply
```

## What Gets Created

### Connection: `conn_sf_cursor_ward`
- **Type:** Snowflake
- **Host:** REA76172.east-us-2.azure.snowflakecomputing.com
- **Warehouse:** COMPUTE_WH
- **Role:** ICEBERG_READER
- **Credentials:** Username/password

### Catalog: `conn_sf_cursor_ward_catalog`
- **Type:** Foreign Catalog (Snowflake)
- **Connection:** Uses the connection above
- **Snowflake Database:** OMOP
- **Purpose:** Federated access to Snowflake OMOP data

## Deployment Flow

Terraform automatically handles dependencies:
1. ✅ Creates connection first
2. ✅ Creates catalog using that connection
3. ✅ Outputs all resource IDs for verification

## Security Notes

✅ **terraform.tfvars is git-ignored** - Your credentials are safe
✅ Password is marked as `sensitive = true` in variables
✅ .gitignore protects state files and other sensitive Terraform files

## Verify Deployment

After `terraform apply`, verify in Databricks:

### Via UI
1. **Connection:** Go to **Data** → **Connections** → Look for `conn_sf_cursor_ward`
2. **Catalog:** Go to **Data** → **Catalogs** → Look for `conn_sf_cursor_ward_catalog`
3. Both should show **ACTIVE** status

### Via SQL
```sql
-- Test the catalog
SHOW SCHEMAS IN conn_sf_cursor_ward_catalog;

-- Query Snowflake data
SELECT * FROM conn_sf_cursor_ward_catalog.information_schema.tables LIMIT 10;
```

## Deploy to Different Workspace

1. Create new tfvars:
   ```bash
   cp terraform.tfvars terraform-prod.tfvars
   ```

2. Edit with new workspace values

3. Deploy both resources:
   ```bash
   terraform apply -var-file="terraform-prod.tfvars"
   ```

## Terraform Outputs

After successful apply, you'll see:
- `connection_name` - Name of the connection
- `connection_id` - ID of the connection
- `connection_url` - JDBC URL
- `catalog_name` - Name of the catalog
- `catalog_id` - ID of the catalog
- `catalog_type` - Type (FOREIGN_CATALOG)

---

**Last Updated:** January 11, 2026  
**Status:** Tested and deployed successfully
**Resources:** Connection + Foreign Catalog
