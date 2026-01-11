# OMOP Semantic Layer - Metric Views

## Overview

This directory contains the Databricks Semantic Layer metric view definitions extracted from `serverless_rde85f_catalog.semantic_omop`. These metric views provide business-friendly analytics on top of the OMOP CDM (Common Data Model) tables in Snowflake.

## Metric Views

### 1. Patient Population Metrics
**File:** `patient_population_metrics.yaml`  
**Source:** PERSON table  
**Purpose:** Demographics and patient population analytics

**Dimensions:**
- Gender (Male/Female/Unknown)
- Age Group (0-17, 18-29, 30-44, 45-64, 65+)
- Race (White, Black, Asian, Other)
- Ethnicity (Hispanic, Non-Hispanic, Unknown)
- State, City, Birth Year, Provider Name

**Measures:**
- Total Patients
- Average Age, Median Age
- Patients With Active Enrollment
- Active Enrollment Rate

---

### 2. Clinical Encounter Metrics
**File:** `clinical_encounter_metrics.yaml`  
**Source:** VISIT_OCCURRENCE table  
**Purpose:** Healthcare visit and encounter analytics

**Dimensions:**
- Visit Type (Inpatient, Outpatient, ER, Other)
- Visit Year, Month, Date, Day of Week
- Care Site, Provider Name
- Patient Gender, Patient Age Group

**Measures:**
- Total Visits, Unique Patients
- Visits Per Patient
- Inpatient/Outpatient/Emergency Visits
- Average/Total Length of Stay Days
- ER Utilization Rate

---

### 3. Condition Metrics
**File:** `condition_metrics.yaml`  
**Source:** CONDITION_OCCURRENCE table  
**Purpose:** Disease and condition analytics

**Dimensions:**
- Condition Name, Condition Type
- Diagnosis Year, Month
- Patient Gender, Patient Age Group
- Provider Name

**Measures:**
- Total Conditions Recorded
- Unique Patients With Conditions
- Conditions Per Patient
- Chronic Conditions
- Acute Conditions

---

### 4. Lab & Vitals Metrics
**File:** `lab_vitals_metrics.yaml`  
**Source:** MEASUREMENT table  
**Purpose:** Laboratory results and vital signs analytics

**Dimensions:**
- Measurement Type, Measurement Name
- Measurement Year, Month
- Value Range (Normal/Abnormal)
- Patient Gender, Patient Age Group

**Measures:**
- Total Measurements
- Unique Patients Tested
- Average/Median Value
- Abnormal Results
- Abnormal Result Rate

---

### 5. Medication Utilization Metrics
**File:** `medication_utilization_metrics.yaml`  
**Source:** DRUG_EXPOSURE table  
**Purpose:** Medication prescription and utilization analytics

**Dimensions:**
- Drug Name, Drug Class
- Prescription Year, Month
- Route of Administration
- Patient Gender, Patient Age Group

**Measures:**
- Total Prescriptions
- Unique Patients on Medications
- Prescriptions Per Patient
- Patients With Refills
- Average Days Supply

---

### 6. Procedure Utilization Metrics
**File:** `procedure_utilization_metrics.yaml`  
**Source:** PROCEDURE_OCCURRENCE table  
**Purpose:** Medical procedure analytics

**Dimensions:**
- Procedure Name, Procedure Type
- Procedure Year, Month
- Patient Gender, Patient Age Group
- Provider Name

**Measures:**
- Total Procedures
- Unique Patients With Procedures
- Procedures Per Patient
- Inpatient Procedures
- Outpatient Procedures

---

### 7. Provider Performance Metrics
**File:** `provider_performance_metrics.yaml`  
**Source:** PROVIDER table  
**Purpose:** Healthcare provider analytics

**Dimensions:**
- Provider Name, Specialty
- Gender, NPI
- Care Site

**Measures:**
- Total Providers
- Active Providers
- Patients Per Provider
- Visits Per Provider

---

## Deployment

### Prerequisites
- Target catalog and schema must exist
- User must have CREATE VIEW permission on the schema
- Source tables (OMOP CDM) must exist in the referenced catalog

### Method 1: Using Databricks API

Run the deployment script:
```bash
cd semantic_layer
python deploy_metric_views.py --catalog your_catalog --schema your_schema
```

### Method 2: Manual Deployment via SQL

For each metric view, use the SQL editor or notebook:
```sql
USE CATALOG your_catalog;
USE SCHEMA your_schema;

-- Use the "Create from YAML" option in the UI
-- Or use the SQL CREATE METRIC VIEW statement
```

### Method 3: Databricks Asset Bundles

See `deployment/dabs/semantic_layer/` for DAB configuration.

---

## Configuration

### Updating Catalog References

To point the views to a different catalog, update all YAML files:
```bash
# Replace catalog name in all files
sed -i 's/conn_sf_cursor_ward_catalog/new_catalog_name/g' *.yaml
```

### Updating Schema

Currently references `OMOP` schema. To change:
```bash
sed -i 's/\.OMOP\./\.NEW_SCHEMA\./g' *.yaml
```

---

## File Format

Metric views are defined in YAML format (Databricks Semantic Layer v1.1):

```yaml
version: 1.1

source: catalog.schema.table

joins:
  - name: join_alias
    source: catalog.schema.other_table
    "on": source.key = join_alias.key

dimensions:
  - name: Dimension Name
    expr: SQL expression

measures:
  - name: Measure Name
    expr: Aggregation expression
```

---

## References

- [Databricks Semantic Layer Documentation](https://docs.databricks.com/semantic-layer/)
- [OMOP CDM v5.4 Specification](https://ohdsi.github.io/CommonDataModel/)
- [Metric View YAML Specification](https://docs.databricks.com/semantic-layer/metric-views.html)

---

**Extracted from:** `serverless_rde85f_catalog.semantic_omop`  
**Date:** January 11, 2026  
**Updated for:** `conn_sf_cursor_ward_catalog`
