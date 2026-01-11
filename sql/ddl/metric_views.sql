-- Deploy OMOP Semantic Layer Metric Views
-- Target: serverless_rde85f_catalog.semantic_omop_cursor
--
-- IMPORTANT: Metric views in Databricks are defined using YAML format.
-- These cannot be created via SQL DDL directly - they must be created through:
-- 1. Databricks UI (Data > Create > Metric View from YAML)
-- 2. Databricks notebook using Python/SQL
-- 3. Unity Catalog API (from within compute)
--
-- This script creates the views using the system's AI function or notebook approach.

-- First, set the target catalog and schema
USE CATALOG serverless_rde85f_catalog;
USE SCHEMA semantic_omop_cursor;

-- ==============================================================================
-- Option 1: Create via Python in Databricks Notebook
-- ==============================================================================
/*
%python
import yaml

# Read YAML file
with open('/Workspace/path/to/patient_population_metrics.yaml', 'r') as f:
    view_yaml = f.read()

# Create the metric view
spark.sql(f"""
  CREATE OR REPLACE METRIC VIEW patient_population_metrics
  AS
  '{view_yaml}'
""")
*/

-- ==============================================================================
-- Option 2: Individual CREATE statements (simplified)
-- ==============================================================================

-- Note: The full YAML definitions are in semantic_layer/metric_views/*.yaml
-- For production deployment, use Databricks Asset Bundles or the Python script

-- 1. Patient Population Metrics
-- See: semantic_layer/metric_views/patient_population_metrics.yaml

-- 2. Clinical Encounter Metrics  
-- See: semantic_layer/metric_views/clinical_encounter_metrics.yaml

-- 3. Condition Metrics
-- See: semantic_layer/metric_views/condition_metrics.yaml

-- 4. Lab & Vitals Metrics
-- See: semantic_layer/metric_views/lab_vitals_metrics.yaml

-- 5. Medication Utilization Metrics
-- See: semantic_layer/metric_views/medication_utilization_metrics.yaml

-- 6. Procedure Utilization Metrics
-- See: semantic_layer/metric_views/procedure_utilization_metrics.yaml

-- 7. Provider Performance Metrics
-- See: semantic_layer/metric_views/provider_performance_metrics.yaml

-- ==============================================================================
-- Verification Query
-- ==============================================================================

-- After deployment, verify the views exist
SHOW VIEWS IN serverless_rde85f_catalog.semantic_omop_cursor;

-- Check a specific view
DESCRIBE EXTENDED serverless_rde85f_catalog.semantic_omop_cursor.patient_population_metrics;
