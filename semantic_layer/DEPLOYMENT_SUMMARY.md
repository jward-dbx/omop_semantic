# OMOP Semantic Layer Deployment Summary

## What Was Created

### 1. Metric View Definitions (YAML)
**Location**: `semantic_layer/metric_views/`

Seven metric views extracted from `serverless_rde85f_catalog.semantic_omop`:
- `patient_population_metrics.yaml` - Demographics and population analytics
- `clinical_encounter_metrics.yaml` - Visit and encounter analytics
- `condition_metrics.yaml` - Disease and condition analytics
- `lab_vitals_metrics.yaml` - Laboratory and vital signs analytics
- `medication_utilization_metrics.yaml` - Medication prescription analytics
- `procedure_utilization_metrics.yaml` - Medical procedure analytics
- `provider_performance_metrics.yaml` - Healthcare provider analytics

All YAML files updated to reference: `conn_sf_cursor_ward_catalog`

### 2. SQL Deployment Script
**Location**: `sql/ddl/deploy_metric_views.sql`

- Dynamic SQL using `EXECUTE IMMEDIATE` 
- Parameterized with variables: `source_catalog`, `target_catalog`, `target_schema`
- Embeds YAML definitions using `WITH METRICS LANGUAGE YAML` syntax
- Creates/replaces all 7 metric views in one execution

### 3. Databricks Asset Bundle (DABs)
**Location**: `deployment/dabs/semantic_layer/`

**Files**:
- `databricks.yml` - Bundle configuration with dev/prod targets
- `resources/metric_views_job.yml` - Job definition for deployment

**Features**:
- Parameterized for multiple environments
- SQL job task executes deployment script
- Configurable scheduling (currently paused)
- Email notifications on failure
- Tags for environment tracking

### 4. Deployment Tools

**Python Script**: `semantic_layer/generate_sql_deploy.py`
- Generates SQL from YAML files
- Automates catalog substitution
- Ensures consistency between YAML and SQL

**Python Script**: `semantic_layer/deploy_metric_views.py` (deprecated)
- Initial attempt using API
- **Not usable** - Metric views must be created from within UC compute

### 5. Documentation

- `semantic_layer/README.md` - Overview of all metric views
- `docs/recipes/deploy_metric_views.md` - Complete deployment guide
- `sql/ddl/metric_views.sql` - Reference SQL (notes only)

## How to Deploy

### Quick Start

```bash
# 1. Set variables in databricks.yml or export them
cd deployment/dabs/semantic_layer

# 2. Get SQL warehouse ID
databricks warehouses list

# 3. Update databricks.yml with your warehouse ID

# 4. Validate and deploy
databricks bundle validate --target dev
databricks bundle deploy --target dev
databricks bundle run deploy_metric_views --target dev
```

### Manual Deployment

```sql
-- In Databricks SQL Editor or Notebook
SET VAR source_catalog = 'conn_sf_cursor_ward_catalog';
SET VAR target_catalog = 'serverless_rde85f_catalog';
SET VAR target_schema = 'semantic_omop_cursor';

-- Execute the sql/ddl/deploy_metric_views.sql file
```

## Target Environment

**Current Configuration** (Dev):
- **Source Catalog**: `conn_sf_cursor_ward_catalog` (Snowflake OMOP database)
- **Target Catalog**: `serverless_rde85f_catalog`
- **Target Schema**: `semantic_omop_cursor`
- **Workspace**: `https://fe-sandbox-serverless-rde85f.cloud.databricks.com`

## Key Learnings

1. **Metric views cannot be created via API** from outside UC compute
2. **YAML-based definitions** embedded in SQL DDL is the standard approach
3. **Dynamic SQL with EXECUTE IMMEDIATE** enables parameterization across environments
4. **DABs with SQL job tasks** is the recommended CI/CD pattern
5. **Querying metric views** requires `MEASURE()` function - `SELECT *` doesn't work

## Next Steps

To actually deploy the views to the workspace:

1. **Get SQL Warehouse ID**:
   ```bash
   databricks warehouses list --output json | jq -r '.warehouses[0].id'
   ```

2. **Update DABs config** with warehouse ID

3. **Deploy and run**:
   ```bash
   cd deployment/dabs/semantic_layer
   databricks bundle deploy --target dev
   databricks bundle run deploy_metric_views --target dev --wait
   ```

4. **Verify in SQL**:
   ```sql
   SHOW VIEWS IN serverless_rde85f_catalog.semantic_omop_cursor;
   
   SELECT 
     Gender,
     MEASURE(`Total Patients`)
   FROM serverless_rde85f_catalog.semantic_omop_cursor.patient_population_metrics
   GROUP BY Gender;
   ```

## File Structure

```
omop_semantic/
├── semantic_layer/
│   ├── README.md                      # Overview of metric views
│   ├── generate_sql_deploy.py         # SQL generator
│   ├── deploy_metric_views.py         # (deprecated - API attempt)
│   └── metric_views/
│       ├── patient_population_metrics.yaml
│       ├── clinical_encounter_metrics.yaml
│       ├── condition_metrics.yaml
│       ├── lab_vitals_metrics.yaml
│       ├── medication_utilization_metrics.yaml
│       ├── procedure_utilization_metrics.yaml
│       └── provider_performance_metrics.yaml
├── sql/ddl/
│   └── deploy_metric_views.sql        # Deployment SQL script
├── deployment/dabs/semantic_layer/
│   ├── databricks.yml                 # Bundle configuration
│   └── resources/
│       └── metric_views_job.yml       # Job definition
└── docs/recipes/
    └── deploy_metric_views.md         # Deployment guide
```

---

**Created**: January 11, 2026  
**Target Schema**: `serverless_rde85f_catalog.semantic_omop_cursor`  
**Status**: Ready for deployment (pending SQL warehouse configuration)
