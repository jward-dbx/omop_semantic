# OMOP Semantic Layer - Genie Space

## Overview

This directory contains the extracted configuration and deployment tooling for the OMOP Semantic Layer Genie Space.

## Contents

```
resources/genie/
├── omop_semantic_layer_export.json       # Full API export (with serialized_space)
├── omop_semantic_layer_config.json       # Parsed serialized_space structure
├── deploy_genie_space.py                 # Deployment script
└── README.md                             # This file
```

## Genie Space Details

**Name**: OMOP Semantic Layer  
**Space ID**: `01f0e4ce153d10029169af35dcd82266`  
**Warehouse**: `330b45fb0f90f788`

### Metric Views (7 total)

1. **patient_population_metrics** - Demographics and population analytics
2. **clinical_encounter_metrics** - Healthcare visit and encounter data
3. **condition_metrics** - Disease and diagnosis tracking
4. **lab_vitals_metrics** - Laboratory results and vital signs
5. **medication_utilization_metrics** - Medication prescriptions and adherence
6. **procedure_utilization_metrics** - Medical procedures performed
7. **provider_performance_metrics** - Healthcare provider analytics

### Features

- **13 Sample Questions** - Pre-configured queries for common analytics
- **8 Example SQLs** - Reference queries with usage guidance
- **Text Instructions** - Healthcare terminology and query patterns
- **Column Configurations** - Optimized for value dictionaries and examples

## Quick Deployment

### Prerequisites

```bash
# Ensure you have Python 3 and requests library
pip install requests
```

### Deploy New Genie Space

```bash
cd /Users/justin.ward/omop_semantic

# Deploy with default name
python3 resources/genie/deploy_genie_space.py \
  --warehouse-id "YOUR_WAREHOUSE_ID"

# Deploy with custom name
python3 resources/genie/deploy_genie_space.py \
  --name "OMOP Semantic Layer - Production" \
  --warehouse-id "YOUR_WAREHOUSE_ID"
```

### Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `--name` | No | "OMOP Semantic Layer - Cursor Deployed" | Display name for the space |
| `--warehouse-id` | **Yes** | None | SQL warehouse ID |
| `--workspace-url` | No | vending machine URL | Target workspace |
| `--token` | No | From config | Access token |
| `--config-file` | No | `omop_semantic_layer_export.json` | Configuration file |

## Configuration Structure

The Genie space configuration includes:

### 1. Config
- **sample_questions**: 13 pre-defined questions users can click
- Questions are sorted by ID (required by API)

### 2. Data Sources
- **metric_views**: 7 OMOP metric views
- **column_configs**: Column-level settings for each view
  - `get_example_values`: Show example values to AI
  - `build_value_dictionary`: Build unique value list for categorical columns

### 3. Instructions
- **text_instructions**: Healthcare terminology, query patterns, quality metrics
- **example_question_sqls**: 8 reference queries with usage guidance
- **sql_snippets**: (None in current config, but supported)

## Sample Questions

The space includes these pre-configured questions:

1. How many patients do we have by age group and gender?
2. Show me total visits by type in the last year
3. What's the average length of stay for inpatient admissions?
4. How many patients had ER visits?
5. What is the prevalence of Type 2 Diabetes in our population?
6. Show me the top 10 conditions by patient count
7. How many patients have both diabetes and hypertension?
8. What are the most commonly prescribed medications?
9. How many patients are on chronic medications (90+ days)?
10. Show me blood pressure control rates for hypertensive patients
11. What's the average HbA1c for diabetic patients?
12. What percentage of diabetes patients have HbA1c under control (<7%)?
13. What is the demographic breakdown of our patient population?

## Deployment History

| Date | Space ID | Name | Status |
|------|----------|------|--------|
| 2026-01-11 | `01f0e4ce153d10029169af35dcd82266` | OMOP Semantic Layer | ✅ Original |
| 2026-01-11 | `01f0ef0a7cde1f6da7d1330a070fda34` | OMOP Semantic Layer - Cursor Deployed | ✅ Test deployment |

## Updating the Space

To modify the Genie space configuration:

1. **Export current config** (if needed):
   ```bash
   curl -X GET \
     "https://[WORKSPACE]/api/2.0/genie/spaces/[SPACE_ID]?include_serialized_space=true" \
     -H "Authorization: Bearer [TOKEN]" > updated_config.json
   ```

2. **Modify the JSON files** in this directory

3. **Redeploy** using the deployment script

## Troubleshooting

### Common Issues

**Error: Warehouse not found**
- Verify warehouse ID with: `databricks sql warehouses list`
- Ensure warehouse is running

**Error: Metric views not found**
- Check that all 7 metric views exist in `serverless_rde85f_catalog.semantic_omop`
- Views must be accessible by the user/warehouse

**Error: Invalid serialized_space format**
- Ensure `serialized_space` is a JSON string, not an object
- The script handles this automatically

## References

- [Databricks Genie API Documentation](https://docs.databricks.com/api/workspace/genie)
- [Genie Spaces Guide](../../docs/setup/GENIE.md) - Comprehensive migration guide
- [OMOP CDM v5.4 Specification](https://ohdsi.github.io/CommonDataModel/)

---

**Last Updated**: January 11, 2026  
**Maintainer**: OMOP Semantic Layer Team
