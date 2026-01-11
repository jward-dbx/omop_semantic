# Databricks notebook source
# MAGIC %md
# MAGIC # Deploy OMOP Semantic Layer Metric Views
# MAGIC 
# MAGIC This notebook deploys all 7 metric views to the target schema.

# COMMAND ----------

# MAGIC %sql
# MAGIC SET VAR source_catalog = 'conn_sf_cursor_ward_catalog';
# MAGIC SET VAR target_catalog = 'serverless_rde85f_catalog';
# MAGIC SET VAR target_schema = 'semantic_omop_cursor';

# COMMAND ----------

# MAGIC %sql
# MAGIC USE CATALOG IDENTIFIER(:target_catalog);
# MAGIC USE SCHEMA IDENTIFIER(:target_schema);

# COMMAND ----------

# MAGIC %md
# MAGIC ## 1. Patient Population Metrics

# COMMAND ----------

# MAGIC %sql
# MAGIC DECLARE OR REPLACE patient_population_metrics_ddl STRING;
# MAGIC 
# MAGIC SET VAR patient_population_metrics_ddl = 
# MAGIC "CREATE OR REPLACE VIEW patient_population_metrics
# MAGIC COMMENT 'Demographics and patient population analytics based on OMOP PERSON table'
# MAGIC WITH METRICS
# MAGIC LANGUAGE YAML
# MAGIC version: 1.1
# MAGIC 
# MAGIC source: " || :source_catalog || ".OMOP.PERSON
# MAGIC 
# MAGIC joins:
# MAGIC   - name: location
# MAGIC     source: " || :source_catalog || ".OMOP.LOCATION
# MAGIC     \"on\": source.location_id = location.location_id
# MAGIC   - name: observation_period
# MAGIC     source: " || :source_catalog || ".OMOP.OBSERVATION_PERIOD
# MAGIC     \"on\": source.person_id = observation_period.person_id
# MAGIC   - name: provider
# MAGIC     source: " || :source_catalog || ".OMOP.PROVIDER
# MAGIC     \"on\": source.provider_id = provider.provider_id
# MAGIC 
# MAGIC dimensions:
# MAGIC   - name: Gender
# MAGIC     expr: CASE source.gender_concept_id WHEN 8507 THEN 'Male' WHEN 8532 THEN 'Female' ELSE 'Unknown' END
# MAGIC   - name: Age Group
# MAGIC     expr: CASE WHEN YEAR(CURRENT_DATE) - source.year_of_birth < 18 THEN '0-17' WHEN YEAR(CURRENT_DATE) - source.year_of_birth < 30 THEN '18-29' WHEN YEAR(CURRENT_DATE) - source.year_of_birth < 45 THEN '30-44' WHEN YEAR(CURRENT_DATE) - source.year_of_birth < 65 THEN '45-64' ELSE '65+' END
# MAGIC   - name: Race
# MAGIC     expr: CASE source.race_concept_id WHEN 8527 THEN 'White' WHEN 8516 THEN 'Black or African American' WHEN 8515 THEN 'Asian' ELSE 'Other' END
# MAGIC   - name: Ethnicity
# MAGIC     expr: CASE source.ethnicity_concept_id WHEN 38003563 THEN 'Hispanic or Latino' WHEN 38003564 THEN 'Not Hispanic or Latino' ELSE 'Unknown' END
# MAGIC   - name: State
# MAGIC     expr: location.state
# MAGIC   - name: City
# MAGIC     expr: location.city
# MAGIC   - name: Birth Year
# MAGIC     expr: source.year_of_birth
# MAGIC   - name: Provider Name
# MAGIC     expr: provider.provider_name
# MAGIC 
# MAGIC measures:
# MAGIC   - name: Total Patients
# MAGIC     expr: COUNT(DISTINCT source.person_id)
# MAGIC   - name: Average Age
# MAGIC     expr: AVG(YEAR(CURRENT_DATE) - source.year_of_birth)
# MAGIC   - name: Median Age
# MAGIC     expr: PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY YEAR(CURRENT_DATE) - source.year_of_birth)
# MAGIC   - name: Patients With Active Enrollment
# MAGIC     expr: COUNT(DISTINCT CASE WHEN observation_period.observation_period_end_date >= CURRENT_DATE THEN source.person_id END)
# MAGIC   - name: Active Enrollment Rate
# MAGIC     expr: COUNT(DISTINCT CASE WHEN observation_period.observation_period_end_date >= CURRENT_DATE THEN source.person_id END) * 100.0 / NULLIF(COUNT(DISTINCT source.person_id), 0)
# MAGIC ";
# MAGIC 
# MAGIC EXECUTE IMMEDIATE patient_population_metrics_ddl;
# MAGIC SELECT 'Created: patient_population_metrics' AS status;

# COMMAND ----------

# MAGIC %md
# MAGIC ## Verify Deployment

# COMMAND ----------

# MAGIC %sql
# MAGIC SHOW VIEWS IN serverless_rde85f_catalog.semantic_omop_cursor;

# COMMAND ----------

# MAGIC %md
# MAGIC *Note: This is a condensed version showing only the first view. Upload the full SQL script from `sql/ddl/deploy_metric_views.sql` for all 7 views.*
