-- =============================================================================
-- Deploy OMOP Semantic Layer Metric Views
-- =============================================================================
-- This script creates all metric views in the target catalog and schema.
-- It uses parameterized SQL to allow deployment across different environments.
--
-- Parameters (passed as job parameters or widgets):
--   source_catalog: Snowflake catalog containing OMOP CDM tables
--   target_catalog: Databricks catalog where metric views will be created
--   target_schema: Schema within target catalog for metric views
--
-- Usage in Databricks SQL or Notebook:
--   -- Set parameters manually:
--   CREATE WIDGET TEXT source_catalog DEFAULT 'conn_sf_cursor_ward_catalog';
--   CREATE WIDGET TEXT target_catalog DEFAULT 'serverless_rde85f_catalog';
--   CREATE WIDGET TEXT target_schema DEFAULT 'semantic_omop_cursor';
--
-- Usage via DABs job (automatic):
--   cd deployment/dabs/semantic_layer
--   databricks bundle deploy --target dev
--   databricks bundle run deploy_metric_views --target dev
-- =============================================================================

-- Create widgets for parameters (will be set by job or manually)
CREATE WIDGET TEXT source_catalog DEFAULT 'conn_sf_cursor_ward_catalog';
CREATE WIDGET TEXT target_catalog DEFAULT 'serverless_rde85f_catalog';
CREATE WIDGET TEXT target_schema DEFAULT 'semantic_omop_cursor';

-- Set the target catalog and schema for the metric view objects
USE CATALOG IDENTIFIER(getArgument('target_catalog'));
USE SCHEMA IDENTIFIER(getArgument('target_schema'));

-- =============================================================================
-- Patient Population Metrics
-- =============================================================================
DECLARE OR REPLACE patient_population_metrics_ddl STRING;

SET VAR patient_population_metrics_ddl = 
"CREATE OR REPLACE VIEW patient_population_metrics
COMMENT 'Demographics and patient population analytics based on OMOP PERSON table'
WITH METRICS
LANGUAGE YAML
version: 1.1

source: " || " || getArgument('source_catalog') || " || ".OMOP.PERSON

joins:
  - name: location
    source: " || " || getArgument('source_catalog') || " || ".OMOP.LOCATION
    "on": source.location_id = location.location_id
  - name: observation_period
    source: " || " || getArgument('source_catalog') || " || ".OMOP.OBSERVATION_PERIOD
    "on": source.person_id = observation_period.person_id
  - name: provider
    source: " || " || getArgument('source_catalog') || " || ".OMOP.PROVIDER
    "on": source.provider_id = provider.provider_id

dimensions:
  - name: Gender
    expr: CASE source.gender_concept_id WHEN 8507 THEN 'Male' WHEN 8532 THEN 'Female'
      ELSE 'Unknown' END
  - name: Age Group
    expr: CASE WHEN YEAR(CURRENT_DATE) - source.year_of_birth < 18 THEN '0-17' WHEN
      YEAR(CURRENT_DATE) - source.year_of_birth < 30 THEN '18-29' WHEN YEAR(CURRENT_DATE)
      - source.year_of_birth < 45 THEN '30-44' WHEN YEAR(CURRENT_DATE) - source.year_of_birth
      < 65 THEN '45-64' ELSE '65+' END
  - name: Race
    expr: CASE source.race_concept_id WHEN 8527 THEN 'White' WHEN 8516 THEN 'Black
      or African American' WHEN 8515 THEN 'Asian' ELSE 'Other' END
  - name: Ethnicity
    expr: CASE source.ethnicity_concept_id WHEN 38003563 THEN 'Hispanic or Latino'
      WHEN 38003564 THEN 'Not Hispanic or Latino' ELSE 'Unknown' END
  - name: State
    expr: location.state
  - name: City
    expr: location.city
  - name: Birth Year
    expr: source.year_of_birth
  - name: Provider Name
    expr: provider.provider_name

measures:
  - name: Total Patients
    expr: COUNT(DISTINCT source.person_id)
  - name: Average Age
    expr: AVG(YEAR(CURRENT_DATE) - source.year_of_birth)
  - name: Median Age
    expr: PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY YEAR(CURRENT_DATE) - source.year_of_birth)
  - name: Patients With Active Enrollment
    expr: COUNT(DISTINCT CASE WHEN observation_period.observation_period_end_date
      >= CURRENT_DATE THEN source.person_id END)
  - name: Active Enrollment Rate
    expr: "COUNT(DISTINCT CASE WHEN observation_period.observation_period_end_date\
      \ >= CURRENT_DATE THEN source.person_id END) * 100.0 / NULLIF(COUNT(DISTINCT\
      \ source.person_id), 0)"
";

EXECUTE IMMEDIATE patient_population_metrics_ddl;
SELECT 'Created: patient_population_metrics' AS status;

-- =============================================================================
-- Clinical Encounter Metrics
-- =============================================================================
DECLARE OR REPLACE clinical_encounter_metrics_ddl STRING;

SET VAR clinical_encounter_metrics_ddl = 
"CREATE OR REPLACE VIEW clinical_encounter_metrics
COMMENT 'Healthcare visit and encounter analytics based on OMOP VISIT_OCCURRENCE table'
WITH METRICS
LANGUAGE YAML
version: 1.1

source: " || " || getArgument('source_catalog') || " || ".OMOP.VISIT_OCCURRENCE

joins:
  - name: person
    source: " || " || getArgument('source_catalog') || " || ".OMOP.PERSON
    "on": source.person_id = person.person_id
  - name: care_site
    source: " || " || getArgument('source_catalog') || " || ".OMOP.CARE_SITE
    "on": source.care_site_id = care_site.care_site_id
  - name: provider
    source: " || " || getArgument('source_catalog') || " || ".OMOP.PROVIDER
    "on": source.provider_id = provider.provider_id

dimensions:
  - name: Visit Type
    expr: CASE source.visit_concept_id WHEN 9201 THEN 'Inpatient' WHEN 9202 THEN 'Outpatient'
      WHEN 9203 THEN 'Emergency Room' ELSE 'Other' END
  - name: Visit Year
    expr: YEAR(source.visit_start_date)
  - name: Visit Month
    expr: "DATE_TRUNC('MONTH', source.visit_start_date)"
  - name: Visit Date
    expr: source.visit_start_date
  - name: Day of Week
    expr: DAYOFWEEK(source.visit_start_date)
  - name: Care Site
    expr: care_site.care_site_name
  - name: Provider Name
    expr: provider.provider_name
  - name: Patient Gender
    expr: CASE person.gender_concept_id WHEN 8507 THEN 'Male' WHEN 8532 THEN 'Female'
      ELSE 'Unknown' END
  - name: Patient Age Group
    expr: CASE WHEN YEAR(source.visit_start_date) - person.year_of_birth < 18 THEN
      '0-17' WHEN YEAR(source.visit_start_date) - person.year_of_birth < 30 THEN '18-29'
      WHEN YEAR(source.visit_start_date) - person.year_of_birth < 45 THEN '30-44'
      WHEN YEAR(source.visit_start_date) - person.year_of_birth < 65 THEN '45-64'
      ELSE '65+' END

measures:
  - name: Total Visits
    expr: COUNT(source.visit_occurrence_id)
  - name: Unique Patients
    expr: COUNT(DISTINCT source.person_id)
  - name: Visits Per Patient
    expr: "COUNT(source.visit_occurrence_id) * 1.0 / NULLIF(COUNT(DISTINCT source.person_id),\
      \ 0)"
  - name: Inpatient Visits
    expr: COUNT(CASE WHEN source.visit_concept_id = 9201 THEN source.visit_occurrence_id
      END)
  - name: Outpatient Visits
    expr: COUNT(CASE WHEN source.visit_concept_id = 9202 THEN source.visit_occurrence_id
      END)
  - name: Emergency Visits
    expr: COUNT(CASE WHEN source.visit_concept_id = 9203 THEN source.visit_occurrence_id
      END)
  - name: Average Length of Stay Days
    expr: "AVG(DATEDIFF(source.visit_end_date, source.visit_start_date))"
  - name: Total Length of Stay Days
    expr: "SUM(DATEDIFF(source.visit_end_date, source.visit_start_date))"
  - name: ER Utilization Rate
    expr: "COUNT(CASE WHEN source.visit_concept_id = 9203 THEN source.visit_occurrence_id\
      \ END) * 100.0 / NULLIF(COUNT(source.visit_occurrence_id), 0)"
";

EXECUTE IMMEDIATE clinical_encounter_metrics_ddl;
SELECT 'Created: clinical_encounter_metrics' AS status;

-- =============================================================================
-- Condition Metrics
-- =============================================================================
DECLARE OR REPLACE condition_metrics_ddl STRING;

SET VAR condition_metrics_ddl = 
"CREATE OR REPLACE VIEW condition_metrics
COMMENT 'Disease and condition analytics based on OMOP CONDITION_OCCURRENCE table'
WITH METRICS
LANGUAGE YAML
version: 1.1

source: " || " || getArgument('source_catalog') || " || ".OMOP.CONDITION_OCCURRENCE

joins:
  - name: person
    source: " || " || getArgument('source_catalog') || " || ".OMOP.PERSON
    "on": source.person_id = person.person_id
  - name: concept
    source: " || " || getArgument('source_catalog') || " || ".OMOP.CONCEPT
    "on": source.condition_concept_id = concept.concept_id
  - name: visit
    source: " || " || getArgument('source_catalog') || " || ".OMOP.VISIT_OCCURRENCE
    "on": source.visit_occurrence_id = visit.visit_occurrence_id
  - name: provider
    source: " || " || getArgument('source_catalog') || " || ".OMOP.PROVIDER
    "on": source.provider_id = provider.provider_id

dimensions:
  - name: Condition Name
    expr: concept.concept_name
  - name: Diagnosis Year
    expr: YEAR(source.condition_start_date)
  - name: Diagnosis Month
    expr: "DATE_TRUNC('MONTH', source.condition_start_date)"
  - name: Condition Category
    expr: CASE WHEN concept.concept_name LIKE '%diabetes%' THEN 'Diabetes' WHEN concept.concept_name
      LIKE '%hypertens%' THEN 'Hypertension' WHEN concept.concept_name LIKE '%pneumonia%'
      THEN 'Respiratory' WHEN concept.concept_name LIKE '%chest pain%' THEN 'Cardiovascular'
      ELSE 'Other' END
  - name: Patient Gender
    expr: CASE person.gender_concept_id WHEN 8507 THEN 'Male' WHEN 8532 THEN 'Female'
      ELSE 'Unknown' END
  - name: Patient Age Group
    expr: CASE WHEN YEAR(source.condition_start_date) - person.year_of_birth < 18
      THEN '0-17' WHEN YEAR(source.condition_start_date) - person.year_of_birth <
      30 THEN '18-29' WHEN YEAR(source.condition_start_date) - person.year_of_birth
      < 45 THEN '30-44' WHEN YEAR(source.condition_start_date) - person.year_of_birth
      < 65 THEN '45-64' ELSE '65+' END
  - name: Visit Type
    expr: CASE visit.visit_concept_id WHEN 9201 THEN 'Inpatient' WHEN 9202 THEN 'Outpatient'
      WHEN 9203 THEN 'Emergency Room' ELSE 'Other' END
  - name: Provider Name
    expr: provider.provider_name

measures:
  - name: Total Diagnoses
    expr: COUNT(source.condition_occurrence_id)
  - name: Unique Patients With Condition
    expr: COUNT(DISTINCT source.person_id)
  - name: Prevalence Rate Per 100 Patients
    expr: COUNT(DISTINCT source.person_id) * 100.0
  - name: Diagnoses Per Patient
    expr: "COUNT(source.condition_occurrence_id) * 1.0 / NULLIF(COUNT(DISTINCT source.person_id),\
      \ 0)"
  - name: Active Conditions
    expr: COUNT(CASE WHEN source.condition_end_date IS NULL OR source.condition_end_date
      >= CURRENT_DATE THEN source.condition_occurrence_id END)
  - name: Resolved Conditions
    expr: COUNT(CASE WHEN source.condition_end_date < CURRENT_DATE THEN source.condition_occurrence_id
      END)
  - name: Diabetes Patients
    expr: COUNT(DISTINCT CASE WHEN concept.concept_name LIKE '%diabetes%' THEN source.person_id
      END)
  - name: Hypertension Patients
    expr: COUNT(DISTINCT CASE WHEN concept.concept_name LIKE '%hypertens%' THEN source.person_id
      END)
";

EXECUTE IMMEDIATE condition_metrics_ddl;
SELECT 'Created: condition_metrics' AS status;

-- =============================================================================
-- Lab Vitals Metrics
-- =============================================================================
DECLARE OR REPLACE lab_vitals_metrics_ddl STRING;

SET VAR lab_vitals_metrics_ddl = 
"CREATE OR REPLACE VIEW lab_vitals_metrics
COMMENT 'Laboratory results and vital signs analytics based on OMOP MEASUREMENT table'
WITH METRICS
LANGUAGE YAML
version: 1.1

source: " || " || getArgument('source_catalog') || " || ".OMOP.MEASUREMENT

joins:
  - name: person
    source: " || " || getArgument('source_catalog') || " || ".OMOP.PERSON
    "on": source.person_id = person.person_id
  - name: concept
    source: " || " || getArgument('source_catalog') || " || ".OMOP.CONCEPT
    "on": source.measurement_concept_id = concept.concept_id
  - name: visit
    source: " || " || getArgument('source_catalog') || " || ".OMOP.VISIT_OCCURRENCE
    "on": source.visit_occurrence_id = visit.visit_occurrence_id
  - name: provider
    source: " || " || getArgument('source_catalog') || " || ".OMOP.PROVIDER
    "on": source.provider_id = provider.provider_id

dimensions:
  - name: Measurement Name
    expr: concept.concept_name
  - name: Measurement Type
    expr: CASE WHEN concept.concept_name LIKE '%blood pressure%' THEN 'Vital Signs'
      WHEN concept.concept_name LIKE '%temperature%' THEN 'Vital Signs' WHEN concept.concept_name
      LIKE '%heart rate%' THEN 'Vital Signs' WHEN concept.concept_name LIKE '%glucose%'
      THEN 'Lab Test' WHEN concept.concept_name LIKE '%hemoglobin%' THEN 'Lab Test'
      ELSE 'Other' END
  - name: Measurement Year
    expr: YEAR(source.measurement_date)
  - name: Measurement Month
    expr: "DATE_TRUNC('MONTH', source.measurement_date)"
  - name: Patient Gender
    expr: CASE person.gender_concept_id WHEN 8507 THEN 'Male' WHEN 8532 THEN 'Female'
      ELSE 'Unknown' END
  - name: Patient Age Group
    expr: CASE WHEN YEAR(source.measurement_date) - person.year_of_birth < 18 THEN
      '0-17' WHEN YEAR(source.measurement_date) - person.year_of_birth < 30 THEN '18-29'
      WHEN YEAR(source.measurement_date) - person.year_of_birth < 45 THEN '30-44'
      WHEN YEAR(source.measurement_date) - person.year_of_birth < 65 THEN '45-64'
      ELSE '65+' END
  - name: Result Range Status
    expr: CASE WHEN source.value_as_number < source.range_low THEN 'Below Normal'
      WHEN source.value_as_number > source.range_high THEN 'Above Normal' WHEN source.value_as_number
      BETWEEN source.range_low AND source.range_high THEN 'Normal' ELSE 'Unknown'
      END
  - name: Visit Type
    expr: CASE visit.visit_concept_id WHEN 9201 THEN 'Inpatient' WHEN 9202 THEN 'Outpatient'
      WHEN 9203 THEN 'Emergency Room' ELSE 'Other' END
  - name: Provider Name
    expr: provider.provider_name

measures:
  - name: Total Measurements
    expr: COUNT(source.measurement_id)
  - name: Unique Patients Tested
    expr: COUNT(DISTINCT source.person_id)
  - name: Tests Per Patient
    expr: "COUNT(source.measurement_id) * 1.0 / NULLIF(COUNT(DISTINCT source.person_id),\
      \ 0)"
  - name: Average Value
    expr: AVG(source.value_as_number)
  - name: Median Value
    expr: PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY source.value_as_number)
  - name: Min Value
    expr: MIN(source.value_as_number)
  - name: Max Value
    expr: MAX(source.value_as_number)
  - name: Abnormal Results Count
    expr: COUNT(CASE WHEN source.value_as_number < source.range_low OR source.value_as_number
      > source.range_high THEN source.measurement_id END)
  - name: Abnormal Result Rate
    expr: "COUNT(CASE WHEN source.value_as_number < source.range_low OR source.value_as_number\
      \ > source.range_high THEN source.measurement_id END) * 100.0 / NULLIF(COUNT(source.measurement_id),\
      \ 0)"
  - name: Patients With Abnormal Results
    expr: COUNT(DISTINCT CASE WHEN source.value_as_number < source.range_low OR source.value_as_number
      > source.range_high THEN source.person_id END)
  - name: Hypertensive Readings Count
    expr: COUNT(CASE WHEN concept.concept_name LIKE '%Systolic%' AND source.value_as_number
      >= 140 THEN source.measurement_id END)
  - name: Elevated Glucose Count
    expr: COUNT(CASE WHEN concept.concept_name LIKE '%Glucose%' AND source.value_as_number
      >= 126 THEN source.measurement_id END)
";

EXECUTE IMMEDIATE lab_vitals_metrics_ddl;
SELECT 'Created: lab_vitals_metrics' AS status;

-- =============================================================================
-- Medication Utilization Metrics
-- =============================================================================
DECLARE OR REPLACE medication_utilization_metrics_ddl STRING;

SET VAR medication_utilization_metrics_ddl = 
"CREATE OR REPLACE VIEW medication_utilization_metrics
COMMENT 'Medication prescription and utilization analytics based on OMOP DRUG_EXPOSURE table'
WITH METRICS
LANGUAGE YAML
version: 1.1

source: " || " || getArgument('source_catalog') || " || ".OMOP.DRUG_EXPOSURE

joins:
  - name: person
    source: " || " || getArgument('source_catalog') || " || ".OMOP.PERSON
    "on": source.person_id = person.person_id
  - name: concept
    source: " || " || getArgument('source_catalog') || " || ".OMOP.CONCEPT
    "on": source.drug_concept_id = concept.concept_id
  - name: visit
    source: " || " || getArgument('source_catalog') || " || ".OMOP.VISIT_OCCURRENCE
    "on": source.visit_occurrence_id = visit.visit_occurrence_id
  - name: provider
    source: " || " || getArgument('source_catalog') || " || ".OMOP.PROVIDER
    "on": source.provider_id = provider.provider_id

dimensions:
  - name: Drug Name
    expr: concept.concept_name
  - name: Drug Class
    expr: CASE WHEN concept.concept_name LIKE '%metformin%' THEN 'Antidiabetic' WHEN
      concept.concept_name LIKE '%lisinopril%' THEN 'Antihypertensive' WHEN concept.concept_name
      LIKE '%atorvastatin%' THEN 'Statin' WHEN concept.concept_name LIKE '%albuterol%'
      THEN 'Bronchodilator' ELSE 'Other' END
  - name: Prescription Year
    expr: YEAR(source.drug_exposure_start_date)
  - name: Prescription Month
    expr: "DATE_TRUNC('MONTH', source.drug_exposure_start_date)"
  - name: Patient Gender
    expr: CASE person.gender_concept_id WHEN 8507 THEN 'Male' WHEN 8532 THEN 'Female'
      ELSE 'Unknown' END
  - name: Patient Age Group
    expr: CASE WHEN YEAR(source.drug_exposure_start_date) - person.year_of_birth <
      18 THEN '0-17' WHEN YEAR(source.drug_exposure_start_date) - person.year_of_birth
      < 30 THEN '18-29' WHEN YEAR(source.drug_exposure_start_date) - person.year_of_birth
      < 45 THEN '30-44' WHEN YEAR(source.drug_exposure_start_date) - person.year_of_birth
      < 65 THEN '45-64' ELSE '65+' END
  - name: Prescribing Provider
    expr: provider.provider_name
  - name: Visit Type
    expr: CASE visit.visit_concept_id WHEN 9201 THEN 'Inpatient' WHEN 9202 THEN 'Outpatient'
      WHEN 9203 THEN 'Emergency Room' ELSE 'Other' END

measures:
  - name: Total Prescriptions
    expr: COUNT(source.drug_exposure_id)
  - name: Unique Patients On Medication
    expr: COUNT(DISTINCT source.person_id)
  - name: Prescriptions Per Patient
    expr: "COUNT(source.drug_exposure_id) * 1.0 / NULLIF(COUNT(DISTINCT source.person_id),\
      \ 0)"
  - name: Total Days Supply
    expr: SUM(source.days_supply)
  - name: Average Days Supply
    expr: AVG(source.days_supply)
  - name: Total Quantity Dispensed
    expr: SUM(source.quantity)
  - name: Average Refills
    expr: AVG(source.refills)
  - name: Patients With Refills
    expr: COUNT(DISTINCT CASE WHEN source.refills > 0 THEN source.person_id END)
  - name: Active Prescriptions
    expr: COUNT(CASE WHEN source.drug_exposure_end_date >= CURRENT_DATE THEN source.drug_exposure_id
      END)
  - name: Chronic Medication Users
    expr: COUNT(DISTINCT CASE WHEN source.days_supply >= 90 THEN source.person_id
      END)
";

EXECUTE IMMEDIATE medication_utilization_metrics_ddl;
SELECT 'Created: medication_utilization_metrics' AS status;

-- =============================================================================
-- Procedure Utilization Metrics
-- =============================================================================
DECLARE OR REPLACE procedure_utilization_metrics_ddl STRING;

SET VAR procedure_utilization_metrics_ddl = 
"CREATE OR REPLACE VIEW procedure_utilization_metrics
COMMENT 'Medical procedure analytics based on OMOP PROCEDURE_OCCURRENCE table'
WITH METRICS
LANGUAGE YAML
version: 1.1

source: " || " || getArgument('source_catalog') || " || ".OMOP.PROCEDURE_OCCURRENCE

joins:
  - name: person
    source: " || " || getArgument('source_catalog') || " || ".OMOP.PERSON
    "on": source.person_id = person.person_id
  - name: concept
    source: " || " || getArgument('source_catalog') || " || ".OMOP.CONCEPT
    "on": source.procedure_concept_id = concept.concept_id
  - name: visit
    source: " || " || getArgument('source_catalog') || " || ".OMOP.VISIT_OCCURRENCE
    "on": source.visit_occurrence_id = visit.visit_occurrence_id
  - name: provider
    source: " || " || getArgument('source_catalog') || " || ".OMOP.PROVIDER
    "on": source.provider_id = provider.provider_id

dimensions:
  - name: Procedure Name
    expr: concept.concept_name
  - name: Procedure Category
    expr: CASE WHEN concept.concept_name LIKE '%X-ray%' THEN 'Imaging' WHEN concept.concept_name
      LIKE '%ECG%' OR concept.concept_name LIKE '%Electrocardiogram%' THEN 'Cardiac
      Testing' WHEN concept.concept_name LIKE '%blood pressure%' THEN 'Vital Signs
      Check' ELSE 'Other' END
  - name: Procedure Year
    expr: YEAR(source.procedure_date)
  - name: Procedure Month
    expr: "DATE_TRUNC('MONTH', source.procedure_date)"
  - name: Patient Gender
    expr: CASE person.gender_concept_id WHEN 8507 THEN 'Male' WHEN 8532 THEN 'Female'
      ELSE 'Unknown' END
  - name: Patient Age Group
    expr: CASE WHEN YEAR(source.procedure_date) - person.year_of_birth < 18 THEN '0-17'
      WHEN YEAR(source.procedure_date) - person.year_of_birth < 30 THEN '18-29' WHEN
      YEAR(source.procedure_date) - person.year_of_birth < 45 THEN '30-44' WHEN YEAR(source.procedure_date)
      - person.year_of_birth < 65 THEN '45-64' ELSE '65+' END
  - name: Visit Type
    expr: CASE visit.visit_concept_id WHEN 9201 THEN 'Inpatient' WHEN 9202 THEN 'Outpatient'
      WHEN 9203 THEN 'Emergency Room' ELSE 'Other' END
  - name: Performing Provider
    expr: provider.provider_name

measures:
  - name: Total Procedures
    expr: COUNT(source.procedure_occurrence_id)
  - name: Unique Patients With Procedures
    expr: COUNT(DISTINCT source.person_id)
  - name: Procedures Per Patient
    expr: "COUNT(source.procedure_occurrence_id) * 1.0 / NULLIF(COUNT(DISTINCT source.person_id),\
      \ 0)"
  - name: Imaging Procedures
    expr: COUNT(CASE WHEN concept.concept_name LIKE '%X-ray%' THEN source.procedure_occurrence_id
      END)
  - name: Cardiac Testing Procedures
    expr: COUNT(CASE WHEN concept.concept_name LIKE '%ECG%' OR concept.concept_name
      LIKE '%Electrocardiogram%' THEN source.procedure_occurrence_id END)
  - name: Vital Signs Checks
    expr: COUNT(CASE WHEN concept.concept_name LIKE '%blood pressure%' THEN source.procedure_occurrence_id
      END)
";

EXECUTE IMMEDIATE procedure_utilization_metrics_ddl;
SELECT 'Created: procedure_utilization_metrics' AS status;

-- =============================================================================
-- Provider Performance Metrics
-- =============================================================================
DECLARE OR REPLACE provider_performance_metrics_ddl STRING;

SET VAR provider_performance_metrics_ddl = 
"CREATE OR REPLACE VIEW provider_performance_metrics
COMMENT 'Healthcare provider analytics based on OMOP PROVIDER table'
WITH METRICS
LANGUAGE YAML
version: 1.1

source: " || " || getArgument('source_catalog') || " || ".OMOP.PROVIDER

joins:
  - name: person
    source: " || " || getArgument('source_catalog') || " || ".OMOP.PERSON
    "on": source.provider_id = person.provider_id
  - name: visit
    source: " || " || getArgument('source_catalog') || " || ".OMOP.VISIT_OCCURRENCE
    "on": source.provider_id = visit.provider_id
  - name: care_site
    source: " || " || getArgument('source_catalog') || " || ".OMOP.CARE_SITE
    "on": source.care_site_id = care_site.care_site_id

dimensions:
  - name: Provider Name
    expr: source.provider_name
  - name: Provider Gender
    expr: CASE source.gender_concept_id WHEN 8507 THEN 'Male' WHEN 8532 THEN 'Female'
      ELSE 'Unknown' END
  - name: Care Site
    expr: care_site.care_site_name
  - name: Provider NPI
    expr: source.npi

measures:
  - name: Total Providers
    expr: COUNT(DISTINCT source.provider_id)
  - name: Active Patient Panel Size
    expr: COUNT(DISTINCT person.person_id)
  - name: Average Panel Size
    expr: "COUNT(DISTINCT person.person_id) * 1.0 / NULLIF(COUNT(DISTINCT source.provider_id),\
      \ 0)"
  - name: Total Visits By Provider
    expr: COUNT(visit.visit_occurrence_id)
  - name: Average Visits Per Provider
    expr: "COUNT(visit.visit_occurrence_id) * 1.0 / NULLIF(COUNT(DISTINCT source.provider_id),\
      \ 0)"
";

EXECUTE IMMEDIATE provider_performance_metrics_ddl;
SELECT 'Created: provider_performance_metrics' AS status;

-- =============================================================================
-- Deployment Complete - Summary
-- =============================================================================
SELECT 
  '✅ Metric Views Deployment Complete' AS status,
  getArgument('target_catalog') AS catalog,
  getArgument('target_schema') AS schema,
  getArgument('source_catalog') AS source_catalog,
  '7 metric views created' AS views_created;

-- Show all created views
SHOW VIEWS IN IDENTIFIER(CONCAT(getArgument('target_catalog'), '.', getArgument('target_schema')));
