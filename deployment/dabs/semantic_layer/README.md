# Automated Deployment with Databricks Asset Bundles

## Overview

This Databricks Asset Bundle provides **fully automated, end-to-end deployment** of OMOP semantic layer metric views with **zero manual steps**.

### What Gets Deployed

1. **Serverless SQL Warehouse** - Automatically provisioned for query execution
2. **SQL Deployment Job** - Parameterized job that creates metric views
3. **SQL Script** - Uploaded to workspace automatically
4. **7 Metric Views** - Created in the target schema

### Deployment Flow

```
databricks bundle deploy
         ↓
   Creates Resources:
   - SQL Warehouse (serverless)
   - Deployment Job
   - Uploads SQL script
         ↓
databricks bundle run
         ↓
   Executes Job:
   - Sets parameters
   - Runs SQL script
   - Creates 7 metric views
         ↓
   ✅ Views Ready!
```

## Quick Start

### Prerequisites

```bash
# Install Databricks CLI
curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sh

# Configure authentication
databricks auth login --host https://fe-sandbox-serverless-rde85f.cloud.databricks.com

# Verify connection
databricks workspace list /
```

### Deploy Everything

```bash
cd deployment/dabs/semantic_layer

# Deploy bundle and create views (one command!)
./deploy.sh dev
```

That's it! The script will:
1. ✅ Validate bundle configuration
2. ✅ Deploy all resources (warehouse, job, SQL script)
3. ✅ Run the job to create metric views
4. ✅ Verify deployment

### Manual Steps (if preferred)

```bash
# Step 1: Deploy the bundle
databricks bundle deploy --target dev

# Step 2: Run the job to create views
databricks bundle run deploy_metric_views --target dev
```

## Configuration

### Bundle Structure

```
deployment/dabs/semantic_layer/
├── databricks.yml                 # Main bundle config
├── resources/
│   └── metric_views_job.yml       # Job definition
├── deploy.sh                      # Automated deployment script
└── README.md                      # This file
```

### Parameters

The bundle is parameterized for multi-environment deployment:

| Parameter | Dev Value | Prod Value | Description |
|-----------|-----------|------------|-------------|
| `source_catalog` | `conn_sf_cursor_ward_catalog` | `${PROD_SOURCE_CATALOG}` | Snowflake OMOP catalog |
| `target_catalog` | `serverless_rde85f_catalog` | `${PROD_TARGET_CATALOG}` | Databricks catalog |
| `target_schema` | `semantic_omop_cursor` | `${PROD_TARGET_SCHEMA}` | Schema for views |

### Customizing Environments

Edit `databricks.yml` to add new targets:

```yaml
targets:
  staging:
    mode: development
    workspace:
      host: https://your-staging-workspace.cloud.databricks.com
    variables:
      source_catalog: "staging_snowflake_catalog"
      target_catalog: "staging_databricks_catalog"
      target_schema: "semantic_omop_staging"
```

## Resources Created

### 1. Serverless SQL Warehouse

```yaml
Name: "[dev] OMOP Semantic Layer Warehouse"
Type: Serverless SQL
Size: Small
Auto-stop: 10 minutes
```

**Why Serverless?**
- ✅ No infrastructure management
- ✅ Automatic scaling
- ✅ Pay only for query execution
- ✅ Fast start-up times

### 2. Deployment Job

```yaml
Name: "[dev] Deploy OMOP Metric Views"
Type: SQL Job
Schedule: None (on-demand only)
Parameters:
  - source_catalog
  - target_catalog
  - target_schema
```

**Job Features:**
- Parameterized for flexibility
- Automatic retry on failure
- Email notifications
- Tagged for tracking

### 3. SQL Script

Automatically uploaded to workspace:
```
/Workspace/files/omop_semantic_layer/deploy_metric_views.sql
```

### 4. Metric Views

Seven metric views created in `serverless_rde85f_catalog.semantic_omop_cursor`:

1. `patient_population_metrics`
2. `clinical_encounter_metrics`
3. `condition_metrics`
4. `lab_vitals_metrics`
5. `medication_utilization_metrics`
6. `procedure_utilization_metrics`
7. `provider_performance_metrics`

## Verification

### Check Deployment Status

```bash
# List deployed resources
databricks bundle summary --target dev

# Check job runs
databricks jobs runs list --job-name "[dev] Deploy OMOP Metric Views" --limit 5

# View warehouse
databricks sql warehouses list | grep "OMOP Semantic Layer"
```

### Test Metric Views

In Databricks SQL Editor:

```sql
-- List views
SHOW VIEWS IN serverless_rde85f_catalog.semantic_omop_cursor;

-- Test a view
SELECT 
  Gender,
  MEASURE(`Total Patients`),
  MEASURE(`Average Age`)
FROM serverless_rde85f_catalog.semantic_omop_cursor.patient_population_metrics
GROUP BY Gender;
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Deploy Metric Views

on:
  push:
    branches: [main]
    paths:
      - 'semantic_layer/**'
      - 'deployment/dabs/semantic_layer/**'
      - 'sql/ddl/deploy_metric_views.sql'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Databricks CLI
        run: |
          curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sh
      
      - name: Deploy to Production
        env:
          DATABRICKS_HOST: ${{ secrets.DATABRICKS_HOST }}
          DATABRICKS_TOKEN: ${{ secrets.DATABRICKS_TOKEN }}
        run: |
          cd deployment/dabs/semantic_layer
          ./deploy.sh prod
```

## Troubleshooting

### Common Issues

#### 1. Authentication Error

```bash
Error: failed to authenticate
```

**Solution:**
```bash
# Re-authenticate
databricks auth login --host https://fe-sandbox-serverless-rde85f.cloud.databricks.com
```

#### 2. Bundle Validation Failed

```bash
Error: variable source_catalog is not defined
```

**Solution:** Check `databricks.yml` - ensure all variables are defined for the target.

#### 3. Job Failed

```bash
Error: catalog not found
```

**Solution:** Verify that:
- Source catalog (`conn_sf_cursor_ward_catalog`) exists
- Target schema exists
- You have permissions on both catalogs

#### 4. Views Not Created

**Check job output:**
```bash
# Get recent run ID
RUN_ID=$(databricks jobs runs list --job-name "[dev] Deploy OMOP Metric Views" --limit 1 | jq -r '.runs[0].run_id')

# View logs
databricks jobs runs get-output --run-id $RUN_ID
```

### Manual Rollback

To delete the deployed views:

```sql
USE CATALOG serverless_rde85f_catalog;
USE SCHEMA semantic_omop_cursor;

DROP VIEW IF EXISTS patient_population_metrics;
DROP VIEW IF EXISTS clinical_encounter_metrics;
DROP VIEW IF EXISTS condition_metrics;
DROP VIEW IF EXISTS lab_vitals_metrics;
DROP VIEW IF EXISTS medication_utilization_metrics;
DROP VIEW IF EXISTS procedure_utilization_metrics;
DROP VIEW IF EXISTS provider_performance_metrics;
```

## Updating Metric Views

### Modify Existing Views

1. **Update YAML files** in `semantic_layer/metric_views/`
2. **Regenerate SQL**:
   ```bash
   cd semantic_layer
   python3 generate_sql_deploy.py
   ```
3. **Redeploy**:
   ```bash
   cd ../deployment/dabs/semantic_layer
   ./deploy.sh dev
   ```

### Add New Views

1. **Create new YAML** in `semantic_layer/metric_views/`
2. **Update** `generate_sql_deploy.py` to include new view
3. **Regenerate and deploy** (same as above)

## Cost Optimization

### Serverless SQL Costs

- **Compute**: Billed per DBU (Databricks Unit)
- **Auto-stop**: Warehouse stops after 10 minutes of inactivity
- **Deployment frequency**: Job runs on-demand only

### Cost Estimates

| Operation | Frequency | Estimated Cost |
|-----------|-----------|----------------|
| Initial deployment | Once | ~$0.10 |
| View recreation | On-demand | ~$0.10 |
| Query execution | Per query | Varies by complexity |

**Tip:** For production, consider:
- Scheduling redeployment during off-hours
- Using larger warehouse size for complex queries
- Monitoring DBU consumption via System Tables

## Best Practices

### 1. Environment Separation
- ✅ Use separate workspaces for dev/prod
- ✅ Different catalogs per environment
- ✅ Service principals for production

### 2. Version Control
- ✅ All YAML files in Git
- ✅ Tag releases with semantic versioning
- ✅ Document changes in commit messages

### 3. Testing
- ✅ Deploy to dev first
- ✅ Test queries before promoting to prod
- ✅ Validate joins and measures

### 4. Monitoring
- ✅ Set up job failure alerts
- ✅ Track query performance
- ✅ Review warehouse utilization

## Support

For issues or questions:
1. Check job logs in Databricks UI
2. Review this documentation
3. Contact: justin.ward@databricks.com

---

**Last Updated**: January 11, 2026  
**Bundle Version**: 1.0.0  
**Databricks Runtime**: 14.3 LTS+
