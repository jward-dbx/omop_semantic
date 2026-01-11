#!/usr/bin/env python3
"""Generate SQL deployment script from YAML metric view definitions."""

import yaml
from pathlib import Path

def yaml_to_sql_string(yaml_content: str, indent: int = 0) -> str:
    """Convert YAML content to SQL-safe string with proper escaping."""
    lines = yaml_content.strip().split('\n')
    result = []
    for line in lines:
        # Escape quotes in the line
        escaped = line.replace('"', '\\"')
        result.append(escaped)
    return '\n'.join(result)

def generate_metric_view_ddl(view_name: str, yaml_file: Path, comment: str) -> str:
    """Generate SQL DDL for a single metric view."""
    with open(yaml_file, 'r') as f:
        yaml_content = f.read()
    
    # Remove the version line as it will be added in SQL
    lines = yaml_content.strip().split('\n')
    filtered_lines = [line for line in lines if not line.startswith('version:')]
    yaml_body = '\n'.join(filtered_lines).strip()
    
    # Replace catalog placeholder
    yaml_body = yaml_body.replace('conn_sf_cursor_ward_catalog', '" || :source_catalog || "')
    
    ddl = f'''-- =============================================================================
-- {view_name.replace('_', ' ').title()}
-- =============================================================================
DECLARE OR REPLACE {view_name}_ddl STRING;

SET VAR {view_name}_ddl = 
"CREATE OR REPLACE VIEW {view_name}
COMMENT '{comment}'
WITH METRICS
LANGUAGE YAML
version: 1.1

{yaml_body}
";

EXECUTE IMMEDIATE {view_name}_ddl;
SELECT 'Created: {view_name}' AS status;

'''
    return ddl

# View metadata
views = [
    ('patient_population_metrics', 'Demographics and patient population analytics based on OMOP PERSON table'),
    ('clinical_encounter_metrics', 'Healthcare visit and encounter analytics based on OMOP VISIT_OCCURRENCE table'),
    ('condition_metrics', 'Disease and condition analytics based on OMOP CONDITION_OCCURRENCE table'),
    ('lab_vitals_metrics', 'Laboratory results and vital signs analytics based on OMOP MEASUREMENT table'),
    ('medication_utilization_metrics', 'Medication prescription and utilization analytics based on OMOP DRUG_EXPOSURE table'),
    ('procedure_utilization_metrics', 'Medical procedure analytics based on OMOP PROCEDURE_OCCURRENCE table'),
    ('provider_performance_metrics', 'Healthcare provider analytics based on OMOP PROVIDER table'),
]

# Generate complete SQL script
sql_header = '''-- =============================================================================
-- Deploy OMOP Semantic Layer Metric Views
-- =============================================================================
-- This script creates all metric views in the target catalog and schema.
-- It uses parameterized SQL to allow deployment across different environments.
--
-- Variables:
--   source_catalog: Snowflake catalog containing OMOP CDM tables
--   target_catalog: Databricks catalog where metric views will be created
--   target_schema: Schema within target catalog for metric views
--
-- Usage in Databricks SQL or Notebook:
--   SET VAR source_catalog = 'conn_sf_cursor_ward_catalog';
--   SET VAR target_catalog = 'serverless_rde85f_catalog';
--   SET VAR target_schema = 'semantic_omop_cursor';
--   SOURCE /Workspace/path/to/deploy_metric_views.sql
--
-- Or via DABs job:
--   See deployment/dabs/semantic_layer/ for bundle configuration
-- =============================================================================

-- Set the target catalog and schema for the metric view objects
USE CATALOG IDENTIFIER(:target_catalog);
USE SCHEMA IDENTIFIER(:target_schema);

'''

sql_footer = '''-- =============================================================================
-- Deployment Complete - Summary
-- =============================================================================
SELECT 
  '✅ Metric Views Deployment Complete' AS status,
  :target_catalog AS catalog,
  :target_schema AS schema,
  :source_catalog AS source_catalog,
  '7 metric views created' AS views_created;

-- Show all created views
SHOW VIEWS IN IDENTIFIER(:target_catalog || '.' || :target_schema);
'''

output_file = Path('../sql/ddl/deploy_metric_views.sql')
output_file.parent.mkdir(parents=True, exist_ok=True)

with open(output_file, 'w') as f:
    f.write(sql_header)
    
    for view_name, comment in views:
        yaml_file = Path(f'metric_views/{view_name}.yaml')
        ddl = generate_metric_view_ddl(view_name, yaml_file, comment)
        f.write(ddl)
    
    f.write(sql_footer)

print(f"✅ Generated: {output_file}")
print(f"   Total views: {len(views)}")
