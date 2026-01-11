# Deployment Guide

This guide covers deploying the OMOP Semantic project to Databricks workspaces.

## Prerequisites

- Databricks workspace access
- Databricks CLI installed and configured
- Unity Catalog enabled
- Appropriate permissions to create catalogs/schemas

## Deployment Methods

### Method 1: Databricks Asset Bundles (Recommended)

DABs provide infrastructure-as-code for Databricks resources.

#### 1. Install Databricks CLI

```bash
# Install via pip
pip install databricks-cli

# Or via curl (macOS/Linux)
curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sh
```

#### 2. Configure Authentication

```bash
# Using profile
databricks configure --profile vending-machine

# Or set environment variables
export DATABRICKS_HOST="https://fe-sandbox-serverless-rde85f.cloud.databricks.com"
export DATABRICKS_TOKEN="dapi..."
```

#### 3. Validate Bundle

```bash
cd /path/to/omop_semantic
databricks bundle validate
```

#### 4. Deploy to Development

```bash
databricks bundle deploy -t dev
```

#### 5. Deploy to Production

```bash
databricks bundle deploy -t prod
```

### Method 2: Manual Deployment via Workspace

#### 1. Upload Code

```bash
# Upload notebooks
databricks workspace import-dir ./notebooks /Workspace/Projects/omop_semantic/notebooks

# Upload Python modules
databricks fs cp -r ./src dbfs:/mnt/omop_semantic/src/
```

#### 2. Create Jobs Manually

Use the Databricks UI to:
1. Navigate to Workflows
2. Create new job
3. Configure tasks and schedules
4. Set up dependencies

### Method 3: CI/CD Pipeline

For automated deployments, integrate with GitHub Actions or Azure DevOps.

#### GitHub Actions Example

```yaml
name: Deploy to Databricks

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to Databricks
        run: |
          databricks bundle deploy -t prod
        env:
          DATABRICKS_TOKEN: ${{ secrets.DATABRICKS_TOKEN }}
          DATABRICKS_HOST: ${{ secrets.DATABRICKS_HOST }}
```

## Environment Configuration

### Development (vending-machine)

```yaml
catalog: dev_omop
schema: cdm_54
warehouse_id: <warehouse-id>
cluster_policy: standard
```

### Production

```yaml
catalog: prod_omop
schema: cdm_54
warehouse_id: <prod-warehouse-id>
cluster_policy: production
enable_autoscaling: true
min_workers: 2
max_workers: 8
```

## Initial Setup Tasks

After deployment, run these one-time setup tasks:

### 1. Create Unity Catalog Structure

```sql
-- Create catalogs
CREATE CATALOG IF NOT EXISTS dev_omop;
CREATE CATALOG IF NOT EXISTS prod_omop;

-- Create schemas
CREATE SCHEMA IF NOT EXISTS dev_omop.bronze_raw;
CREATE SCHEMA IF NOT EXISTS dev_omop.silver_clean;
CREATE SCHEMA IF NOT EXISTS dev_omop.gold_omop;

-- Set up permissions
GRANT USE CATALOG ON CATALOG dev_omop TO `data_engineers`;
GRANT CREATE SCHEMA ON CATALOG dev_omop TO `data_engineers`;
```

### 2. Load OMOP Vocabularies

```bash
# Upload vocabulary files to DBFS
databricks fs cp ./resources/vocabularies/ dbfs:/mnt/omop_semantic/vocabularies/ --recursive

# Run vocabulary load job
databricks jobs run-now --job-id <vocabulary-load-job-id>
```

### 3. Create OMOP CDM Tables

```bash
# Run DDL scripts
databricks sql query -f ./sql/ddl/01_create_omop_tables.sql
```

## Verification

After deployment, verify:

```bash
# Test SQL connection
databricks sql query "SELECT COUNT(*) FROM dev_omop.gold_omop.person"

# Run integration tests
pytest tests/integration/

# Check data quality
databricks jobs run-now --job-id <data-quality-job-id>
```

## Rollback Procedure

If deployment fails:

```bash
# List bundle deployments
databricks bundle deployments list

# Rollback to previous version
databricks bundle destroy -t dev
git checkout <previous-commit>
databricks bundle deploy -t dev
```

## Monitoring

Post-deployment monitoring:

1. **Job Runs**: Monitor in Databricks Workflows UI
2. **Query Performance**: Check SQL Warehouse query history
3. **Data Quality**: Review quality check results
4. **Costs**: Monitor DBU usage in account console

## Troubleshooting

### Common Issues

**Issue**: Bundle validation fails
- **Solution**: Check `databricks.yml` syntax, ensure all referenced files exist

**Issue**: Authentication errors
- **Solution**: Verify token is valid and not expired, check permissions

**Issue**: Table not found errors
- **Solution**: Ensure catalogs and schemas are created, check USE CATALOG statements

**Issue**: Permission denied
- **Solution**: Verify user/service principal has required privileges

## Best Practices

1. **Use service principals** for production deployments
2. **Test in dev** before deploying to production
3. **Version control** all deployment artifacts
4. **Document changes** in deployment notes
5. **Monitor costs** after deployment
6. **Set up alerts** for failures
7. **Maintain rollback plan** for quick recovery

## Additional Resources

- [Databricks Asset Bundles Documentation](https://docs.databricks.com/dev-tools/bundles/)
- [Unity Catalog Deployment Guide](https://docs.databricks.com/data-governance/unity-catalog/)
- [Databricks CLI Reference](https://docs.databricks.com/dev-tools/cli/)

---

*Last updated: January 11, 2026*
