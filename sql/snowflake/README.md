# Snowflake SQL Scripts

This directory contains SQL scripts for setting up and managing the Snowflake environment that serves as the external data source for the OMOP Semantic Layer.

## Scripts

### 01_setup_environment.sql
Sets up the Snowflake environment with necessary objects:
- Users and roles
- Databases and schemas
- Volumes and storage
- Permissions and grants

**Run this first** before populating data.

### 02_populate_omop_sample_data.sql
Populates OMOP CDM tables with sample data for testing and development.

**Run this second** after environment setup is complete.

## Execution Order

```bash
# 1. Setup environment
snowsql -f 01_setup_environment.sql

# 2. Populate sample data
snowsql -f 02_populate_omop_sample_data.sql
```

## Notes

- These scripts are designed to run in Snowflake (not Databricks)
- Requires appropriate Snowflake admin privileges
- The objects created here are referenced by the Databricks Unity Catalog connection
- See `deployment/terraform/connections/` for the Databricks connection configuration
