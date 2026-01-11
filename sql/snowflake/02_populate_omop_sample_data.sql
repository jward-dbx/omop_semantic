-- =============================================================================
-- OMOP CDM v5.4 - Snowflake Sample Data Population
-- =============================================================================
-- This script creates OMOP CDM tables and populates them with synthetic sample
-- data for testing and development purposes.
--
-- Dataset Summary:
--   - 15 patients with diverse demographics
--   - 32 visits (inpatient, outpatient, emergency)
--   - 16 condition occurrences
--   - 15 drug exposures
--   - 18 procedures
--   - 45 measurements (labs and vitals)
--
-- Prerequisites:
--   - Run 01_setup_environment.sql first
--   - Set proper database/schema context (e.g., USE SCHEMA OMOP.OMOP;)
--
-- Usage:
--   Execute this script in Snowflake within the target schema
-- =============================================================================

-- =============================================================================
-- 1. CREATE VOCABULARY TABLES
-- =============================================================================

CREATE OR REPLACE TABLE VOCABULARY (
    vocabulary_id VARCHAR(20) NOT NULL,
    vocabulary_name VARCHAR(255) NOT NULL,
    vocabulary_reference VARCHAR(255),
    vocabulary_version VARCHAR(255),
    vocabulary_concept_id INTEGER NOT NULL
);

CREATE OR REPLACE TABLE DOMAIN (
    domain_id VARCHAR(20) NOT NULL,
    domain_name VARCHAR(255) NOT NULL,
    domain_concept_id INTEGER NOT NULL
);

CREATE OR REPLACE TABLE CONCEPT (
    concept_id INTEGER NOT NULL,
    concept_name VARCHAR(255) NOT NULL,
    domain_id VARCHAR(20) NOT NULL,
    vocabulary_id VARCHAR(20) NOT NULL,
    concept_class_id VARCHAR(20) NOT NULL,
    standard_concept VARCHAR(1),
    concept_code VARCHAR(50) NOT NULL,
    valid_start_date DATE NOT NULL,
    valid_end_date DATE NOT NULL,
    invalid_reason VARCHAR(1)
);

-- =============================================================================
-- 2. CREATE STANDARDIZED CLINICAL DATA TABLES
-- =============================================================================

CREATE OR REPLACE TABLE LOCATION (
    location_id INTEGER NOT NULL,
    address_1 VARCHAR(50),
    address_2 VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(2),
    zip VARCHAR(9),
    county VARCHAR(20),
    country VARCHAR(100),
    location_source_value VARCHAR(50),
    latitude NUMERIC,
    longitude NUMERIC
);

CREATE OR REPLACE TABLE CARE_SITE (
    care_site_id INTEGER NOT NULL,
    care_site_name VARCHAR(255),
    place_of_service_concept_id INTEGER,
    location_id INTEGER,
    care_site_source_value VARCHAR(50),
    place_of_service_source_value VARCHAR(50)
);

CREATE OR REPLACE TABLE PROVIDER (
    provider_id INTEGER NOT NULL,
    provider_name VARCHAR(255),
    npi VARCHAR(20),
    dea VARCHAR(20),
    specialty_concept_id INTEGER,
    care_site_id INTEGER,
    year_of_birth INTEGER,
    gender_concept_id INTEGER,
    provider_source_value VARCHAR(50),
    specialty_source_value VARCHAR(50),
    specialty_source_concept_id INTEGER,
    gender_source_value VARCHAR(50),
    gender_source_concept_id INTEGER
);

CREATE OR REPLACE TABLE PERSON (
    person_id INTEGER NOT NULL,
    gender_concept_id INTEGER NOT NULL,
    year_of_birth INTEGER NOT NULL,
    month_of_birth INTEGER,
    day_of_birth INTEGER,
    birth_datetime TIMESTAMP,
    race_concept_id INTEGER NOT NULL,
    ethnicity_concept_id INTEGER NOT NULL,
    location_id INTEGER,
    provider_id INTEGER,
    care_site_id INTEGER,
    person_source_value VARCHAR(50),
    gender_source_value VARCHAR(50),
    gender_source_concept_id INTEGER,
    race_source_value VARCHAR(50),
    race_source_concept_id INTEGER,
    ethnicity_source_value VARCHAR(50),
    ethnicity_source_concept_id INTEGER
);

CREATE OR REPLACE TABLE OBSERVATION_PERIOD (
    observation_period_id INTEGER NOT NULL,
    person_id INTEGER NOT NULL,
    observation_period_start_date DATE NOT NULL,
    observation_period_end_date DATE NOT NULL,
    period_type_concept_id INTEGER NOT NULL
);

CREATE OR REPLACE TABLE VISIT_OCCURRENCE (
    visit_occurrence_id INTEGER NOT NULL,
    person_id INTEGER NOT NULL,
    visit_concept_id INTEGER NOT NULL,
    visit_start_date DATE NOT NULL,
    visit_start_datetime TIMESTAMP,
    visit_end_date DATE NOT NULL,
    visit_end_datetime TIMESTAMP,
    visit_type_concept_id INTEGER NOT NULL,
    provider_id INTEGER,
    care_site_id INTEGER,
    visit_source_value VARCHAR(50),
    visit_source_concept_id INTEGER,
    admitted_from_concept_id INTEGER,
    admitted_from_source_value VARCHAR(50),
    discharged_to_concept_id INTEGER,
    discharged_to_source_value VARCHAR(50),
    preceding_visit_occurrence_id INTEGER
);

CREATE OR REPLACE TABLE CONDITION_OCCURRENCE (
    condition_occurrence_id INTEGER NOT NULL,
    person_id INTEGER NOT NULL,
    condition_concept_id INTEGER NOT NULL,
    condition_start_date DATE NOT NULL,
    condition_start_datetime TIMESTAMP,
    condition_end_date DATE,
    condition_end_datetime TIMESTAMP,
    condition_type_concept_id INTEGER NOT NULL,
    condition_status_concept_id INTEGER,
    stop_reason VARCHAR(20),
    provider_id INTEGER,
    visit_occurrence_id INTEGER,
    visit_detail_id INTEGER,
    condition_source_value VARCHAR(50),
    condition_source_concept_id INTEGER,
    condition_status_source_value VARCHAR(50)
);

CREATE OR REPLACE TABLE DRUG_EXPOSURE (
    drug_exposure_id INTEGER NOT NULL,
    person_id INTEGER NOT NULL,
    drug_concept_id INTEGER NOT NULL,
    drug_exposure_start_date DATE NOT NULL,
    drug_exposure_start_datetime TIMESTAMP,
    drug_exposure_end_date DATE NOT NULL,
    drug_exposure_end_datetime TIMESTAMP,
    verbatim_end_date DATE,
    drug_type_concept_id INTEGER NOT NULL,
    stop_reason VARCHAR(20),
    refills INTEGER,
    quantity NUMERIC,
    days_supply INTEGER,
    sig VARCHAR(1000),
    route_concept_id INTEGER,
    lot_number VARCHAR(50),
    provider_id INTEGER,
    visit_occurrence_id INTEGER,
    visit_detail_id INTEGER,
    drug_source_value VARCHAR(50),
    drug_source_concept_id INTEGER,
    route_source_value VARCHAR(50),
    dose_unit_source_value VARCHAR(50)
);

CREATE OR REPLACE TABLE PROCEDURE_OCCURRENCE (
    procedure_occurrence_id INTEGER NOT NULL,
    person_id INTEGER NOT NULL,
    procedure_concept_id INTEGER NOT NULL,
    procedure_date DATE NOT NULL,
    procedure_datetime TIMESTAMP,
    procedure_end_date DATE,
    procedure_end_datetime TIMESTAMP,
    procedure_type_concept_id INTEGER NOT NULL,
    modifier_concept_id INTEGER,
    quantity INTEGER,
    provider_id INTEGER,
    visit_occurrence_id INTEGER,
    visit_detail_id INTEGER,
    procedure_source_value VARCHAR(50),
    procedure_source_concept_id INTEGER,
    modifier_source_value VARCHAR(50)
);

CREATE OR REPLACE TABLE MEASUREMENT (
    measurement_id INTEGER NOT NULL,
    person_id INTEGER NOT NULL,
    measurement_concept_id INTEGER NOT NULL,
    measurement_date DATE NOT NULL,
    measurement_datetime TIMESTAMP,
    measurement_time VARCHAR(10),
    measurement_type_concept_id INTEGER NOT NULL,
    operator_concept_id INTEGER,
    value_as_number NUMERIC,
    value_as_concept_id INTEGER,
    unit_concept_id INTEGER,
    range_low NUMERIC,
    range_high NUMERIC,
    provider_id INTEGER,
    visit_occurrence_id INTEGER,
    visit_detail_id INTEGER,
    measurement_source_value VARCHAR(50),
    measurement_source_concept_id INTEGER,
    unit_source_value VARCHAR(50),
    unit_source_concept_id INTEGER,
    value_source_value VARCHAR(50),
    measurement_event_id INTEGER,
    meas_event_field_concept_id INTEGER
);

-- =============================================================================
-- 3. POPULATE REFERENCE DATA
-- =============================================================================

-- Vocabularies
INSERT INTO VOCABULARY VALUES
    ('SNOMED', 'SNOMED Clinical Terms', 'http://www.snomed.org/', '2024-01', 0),
    ('RxNorm', 'RxNorm', 'https://www.nlm.nih.gov/research/umls/rxnorm/', '2024-01', 0),
    ('LOINC', 'Logical Observation Identifiers Names and Codes', 'https://loinc.org/', '2024-01', 0),
    ('CPT4', 'Current Procedural Terminology', 'https://www.ama-assn.org/', '2024', 0);

-- Domains
INSERT INTO DOMAIN VALUES
    ('Condition', 'Condition', 0),
    ('Drug', 'Drug', 0),
    ('Measurement', 'Measurement', 0),
    ('Procedure', 'Procedure', 0),
    ('Visit', 'Visit', 0),
    ('Gender', 'Gender', 0),
    ('Race', 'Race', 0),
    ('Ethnicity', 'Ethnicity', 0);

-- Core Concepts
INSERT INTO CONCEPT VALUES
    -- Gender
    (8507, 'Male', 'Gender', 'SNOMED', 'Gender', 'S', '248153007', '1970-01-01', '2099-12-31', NULL),
    (8532, 'Female', 'Gender', 'SNOMED', 'Gender', 'S', '248152002', '1970-01-01', '2099-12-31', NULL),
    -- Race
    (8527, 'White', 'Race', 'SNOMED', 'Race', 'S', '413773004', '1970-01-01', '2099-12-31', NULL),
    (8516, 'Black or African American', 'Race', 'SNOMED', 'Race', 'S', '413464008', '1970-01-01', '2099-12-31', NULL),
    (8515, 'Asian', 'Race', 'SNOMED', 'Race', 'S', '413581001', '1970-01-01', '2099-12-31', NULL),
    -- Ethnicity
    (38003563, 'Hispanic or Latino', 'Ethnicity', 'SNOMED', 'Ethnicity', 'S', '414408004', '1970-01-01', '2099-12-31', NULL),
    (38003564, 'Not Hispanic or Latino', 'Ethnicity', 'SNOMED', 'Ethnicity', 'S', '186034007', '1970-01-01', '2099-12-31', NULL),
    -- Visit types
    (9201, 'Inpatient Visit', 'Visit', 'SNOMED', 'Visit', 'S', '32485007', '1970-01-01', '2099-12-31', NULL),
    (9202, 'Outpatient Visit', 'Visit', 'SNOMED', 'Visit', 'S', '281036007', '1970-01-01', '2099-12-31', NULL),
    (9203, 'Emergency Room Visit', 'Visit', 'SNOMED', 'Visit', 'S', '4525004', '1970-01-01', '2099-12-31', NULL),
    -- Conditions
    (201826, 'Type 2 diabetes mellitus', 'Condition', 'SNOMED', 'Clinical Finding', 'S', '44054006', '1970-01-01', '2099-12-31', NULL),
    (316866, 'Hypertensive disorder', 'Condition', 'SNOMED', 'Clinical Finding', 'S', '38341003', '1970-01-01', '2099-12-31', NULL),
    (255848, 'Pneumonia', 'Condition', 'SNOMED', 'Clinical Finding', 'S', '233604007', '1970-01-01', '2099-12-31', NULL),
    (77670, 'Chest pain', 'Condition', 'SNOMED', 'Clinical Finding', 'S', '29857009', '1970-01-01', '2099-12-31', NULL),
    -- Medications
    (1503297, 'Metformin', 'Drug', 'RxNorm', 'Ingredient', 'S', '6809', '1970-01-01', '2099-12-31', NULL),
    (1308216, 'Lisinopril', 'Drug', 'RxNorm', 'Ingredient', 'S', '29046', '1970-01-01', '2099-12-31', NULL),
    (1112807, 'Atorvastatin', 'Drug', 'RxNorm', 'Ingredient', 'S', '83367', '1970-01-01', '2099-12-31', NULL),
    (1136980, 'Albuterol', 'Drug', 'RxNorm', 'Ingredient', 'S', '435', '1970-01-01', '2099-12-31', NULL),
    -- Procedures
    (2108897, 'Chest X-ray', 'Procedure', 'SNOMED', 'Procedure', 'S', '399208008', '1970-01-01', '2099-12-31', NULL),
    (4337543, 'Electrocardiogram', 'Procedure', 'SNOMED', 'Procedure', 'S', '29303009', '1970-01-01', '2099-12-31', NULL),
    (4305964, 'Blood pressure taking', 'Procedure', 'SNOMED', 'Procedure', 'S', '163020007', '1970-01-01', '2099-12-31', NULL),
    -- Measurements
    (3004249, 'Glucose measurement', 'Measurement', 'LOINC', 'Lab Test', 'S', '2345-7', '1970-01-01', '2099-12-31', NULL),
    (3004410, 'Hemoglobin A1c measurement', 'Measurement', 'LOINC', 'Lab Test', 'S', '4548-4', '1970-01-01', '2099-12-31', NULL),
    (3027018, 'Systolic blood pressure', 'Measurement', 'LOINC', 'Clinical Observation', 'S', '8480-6', '1970-01-01', '2099-12-31', NULL),
    (3012888, 'Diastolic blood pressure', 'Measurement', 'LOINC', 'Clinical Observation', 'S', '8462-4', '1970-01-01', '2099-12-31', NULL),
    (3025315, 'Body temperature', 'Measurement', 'LOINC', 'Clinical Observation', 'S', '8310-5', '1970-01-01', '2099-12-31', NULL),
    (3013762, 'Heart rate', 'Measurement', 'LOINC', 'Clinical Observation', 'S', '8867-4', '1970-01-01', '2099-12-31', NULL),
    -- Type concepts
    (32817, 'EHR', 'Type Concept', 'SNOMED', 'Type Concept', 'S', 'EHR', '1970-01-01', '2099-12-31', NULL),
    (32821, 'EHR billing record', 'Type Concept', 'SNOMED', 'Type Concept', 'S', 'EHR Billing', '1970-01-01', '2099-12-31', NULL),
    (44814650, 'Patient Self-Reported', 'Type Concept', 'SNOMED', 'Type Concept', 'S', 'Patient', '1970-01-01', '2099-12-31', NULL);

-- =============================================================================
-- 4. POPULATE INFRASTRUCTURE DATA
-- =============================================================================

-- Locations
INSERT INTO LOCATION VALUES
    (1, '123 Main St', NULL, 'Boston', 'MA', '02108', 'Suffolk', 'USA', 'LOC001', 42.3601, -71.0589),
    (2, '456 Oak Ave', 'Suite 200', 'San Francisco', 'CA', '94102', 'San Francisco', 'USA', 'LOC002', 37.7749, -122.4194),
    (3, '789 Elm St', NULL, 'Chicago', 'IL', '60601', 'Cook', 'USA', 'LOC003', 41.8781, -87.6298);

-- Care Sites
INSERT INTO CARE_SITE VALUES
    (1, 'Boston General Hospital', 9201, 1, 'BGH001', 'Hospital'),
    (2, 'SF Primary Care Clinic', 9202, 2, 'SFPCC001', 'Clinic'),
    (3, 'Chicago Emergency Center', 9203, 3, 'CEC001', 'Emergency Room');

-- Providers
INSERT INTO PROVIDER VALUES
    (1, 'Dr. Sarah Johnson', '1234567890', NULL, 0, 1, 1975, 8532, 'PROV001', 'Internal Medicine', 0, 'F', 0),
    (2, 'Dr. Michael Chen', '2345678901', NULL, 0, 2, 1980, 8507, 'PROV002', 'Family Medicine', 0, 'M', 0),
    (3, 'Dr. Emily Rodriguez', '3456789012', NULL, 0, 3, 1978, 8532, 'PROV003', 'Emergency Medicine', 0, 'F', 0);

-- =============================================================================
-- 5. POPULATE PATIENT DATA (15 patients)
-- =============================================================================

INSERT INTO PERSON VALUES
    (1, 8532, 1965, 3, 15, '1965-03-15 00:00:00', 8527, 38003564, 1, 1, 1, 'PAT001', 'F', 0, 'White', 0, 'Not Hispanic', 0),
    (2, 8507, 1978, 7, 22, '1978-07-22 00:00:00', 8516, 38003564, 2, 2, 2, 'PAT002', 'M', 0, 'Black', 0, 'Not Hispanic', 0),
    (3, 8532, 1990, 11, 8, '1990-11-08 00:00:00', 8515, 38003563, 3, 3, 3, 'PAT003', 'F', 0, 'Asian', 0, 'Hispanic', 0),
    (4, 8507, 1955, 2, 28, '1955-02-28 00:00:00', 8527, 38003564, 1, 1, 1, 'PAT004', 'M', 0, 'White', 0, 'Not Hispanic', 0),
    (5, 8532, 1982, 4, 10, '1982-04-10 00:00:00', 8527, 38003564, 2, 2, 2, 'PAT005', 'F', 0, 'White', 0, 'Not Hispanic', 0),
    (6, 8507, 1948, 9, 5, '1948-09-05 00:00:00', 8527, 38003564, 1, 1, 1, 'PAT006', 'M', 0, 'White', 0, 'Not Hispanic', 0),
    (7, 8532, 1995, 6, 18, '1995-06-18 00:00:00', 8516, 38003564, 3, 3, 3, 'PAT007', 'F', 0, 'Black', 0, 'Not Hispanic', 0),
    (8, 8507, 1970, 11, 30, '1970-11-30 00:00:00', 8515, 38003563, 2, 2, 2, 'PAT008', 'M', 0, 'Asian', 0, 'Hispanic', 0),
    (9, 8532, 1988, 3, 22, '1988-03-22 00:00:00', 8527, 38003564, 1, 1, 1, 'PAT009', 'F', 0, 'White', 0, 'Not Hispanic', 0),
    (10, 8507, 1960, 7, 14, '1960-07-14 00:00:00', 8516, 38003564, 2, 2, 2, 'PAT010', 'M', 0, 'Black', 0, 'Not Hispanic', 0),
    (11, 8532, 2005, 1, 8, '2005-01-08 00:00:00', 8527, 38003564, 3, 3, 3, 'PAT011', 'F', 0, 'White', 0, 'Not Hispanic', 0),
    (12, 8507, 1975, 8, 25, '1975-08-25 00:00:00', 8515, 38003563, 1, 1, 1, 'PAT012', 'M', 0, 'Asian', 0, 'Hispanic', 0),
    (13, 8532, 1992, 12, 3, '1992-12-03 00:00:00', 8516, 38003564, 2, 2, 2, 'PAT013', 'F', 0, 'Black', 0, 'Not Hispanic', 0),
    (14, 8507, 1968, 5, 17, '1968-05-17 00:00:00', 8527, 38003564, 3, 3, 3, 'PAT014', 'M', 0, 'White', 0, 'Not Hispanic', 0),
    (15, 8532, 2000, 10, 9, '2000-10-09 00:00:00', 8527, 38003564, 1, 1, 1, 'PAT015', 'F', 0, 'White', 0, 'Not Hispanic', 0);

-- Observation Periods
INSERT INTO OBSERVATION_PERIOD VALUES
    (1, 1, '2020-01-01', '2024-12-31', 32817),
    (2, 2, '2019-06-15', '2024-12-31', 32817),
    (3, 3, '2021-03-01', '2024-12-31', 32817),
    (4, 4, '2018-01-01', '2024-12-31', 32817),
    (5, 5, '2022-01-01', '2024-12-31', 32817),
    (6, 6, '2015-01-01', '2024-12-31', 32817),
    (7, 7, '2023-03-15', '2024-12-31', 32817),
    (8, 8, '2020-06-01', '2024-12-31', 32817),
    (9, 9, '2021-01-01', '2024-12-31', 32817),
    (10, 10, '2019-01-01', '2024-12-31', 32817),
    (11, 11, '2023-01-01', '2024-12-31', 32817),
    (12, 12, '2018-01-01', '2024-12-31', 32817),
    (13, 13, '2022-06-01', '2024-12-31', 32817),
    (14, 14, '2017-01-01', '2024-12-31', 32817),
    (15, 15, '2023-09-01', '2024-12-31', 32817);

-- =============================================================================
-- 6. POPULATE CLINICAL EVENTS (32 visits)
-- =============================================================================

INSERT INTO VISIT_OCCURRENCE VALUES
    -- Initial 5 visits
    (1, 1, 9202, '2024-01-15', '2024-01-15 09:00:00', '2024-01-15', '2024-01-15 10:30:00', 32817, 1, 1, 'V001', 0, NULL, NULL, NULL, NULL, NULL),
    (2, 1, 9201, '2024-03-10', '2024-03-10 14:00:00', '2024-03-13', '2024-03-13 11:00:00', 32817, 1, 1, 'V002', 0, 9203, 'Emergency', NULL, 'Home', NULL),
    (3, 2, 9202, '2024-02-20', '2024-02-20 10:00:00', '2024-02-20', '2024-02-20 11:00:00', 32817, 2, 2, 'V003', 0, NULL, NULL, NULL, NULL, NULL),
    (4, 3, 9203, '2024-05-05', '2024-05-05 20:30:00', '2024-05-05', '2024-05-05 23:00:00', 32817, 3, 3, 'V004', 0, NULL, NULL, NULL, 'Home', NULL),
    (5, 4, 9202, '2024-06-12', '2024-06-12 14:00:00', '2024-06-12', '2024-06-12 15:00:00', 32817, 1, 1, 'V005', 0, NULL, NULL, NULL, NULL, NULL),
    -- Additional visits (27 more)
    (6, 5, 9202, '2024-02-10', '2024-02-10 10:00:00', '2024-02-10', '2024-02-10 11:00:00', 32817, 2, 2, 'V006', 0, NULL, NULL, NULL, NULL, NULL),
    (7, 5, 9202, '2024-05-15', '2024-05-15 14:00:00', '2024-05-15', '2024-05-15 15:00:00', 32817, 2, 2, 'V007', 0, NULL, NULL, NULL, NULL, NULL),
    (8, 5, 9203, '2024-08-03', '2024-08-03 22:00:00', '2024-08-03', '2024-08-03 23:30:00', 32817, 3, 3, 'V008', 0, NULL, NULL, NULL, 'Home', NULL),
    (9, 6, 9202, '2024-01-20', '2024-01-20 09:00:00', '2024-01-20', '2024-01-20 10:00:00', 32817, 1, 1, 'V009', 0, NULL, NULL, NULL, NULL, NULL),
    (10, 6, 9202, '2024-04-15', '2024-04-15 09:00:00', '2024-04-15', '2024-04-15 10:00:00', 32817, 1, 1, 'V010', 0, NULL, NULL, NULL, NULL, NULL),
    (11, 6, 9201, '2024-07-10', '2024-07-10 16:00:00', '2024-07-15', '2024-07-15 10:00:00', 32817, 1, 1, 'V011', 0, 9203, 'Emergency', NULL, 'SNF', NULL),
    (12, 7, 9202, '2024-03-01', '2024-03-01 10:00:00', '2024-03-01', '2024-03-01 10:30:00', 32817, 3, 3, 'V012', 0, NULL, NULL, NULL, NULL, NULL),
    (13, 7, 9202, '2024-09-15', '2024-09-15 14:00:00', '2024-09-15', '2024-09-15 14:30:00', 32817, 3, 3, 'V013', 0, NULL, NULL, NULL, NULL, NULL),
    (14, 8, 9202, '2024-02-05', '2024-02-05 11:00:00', '2024-02-05', '2024-02-05 12:00:00', 32817, 2, 2, 'V014', 0, NULL, NULL, NULL, NULL, NULL),
    (15, 8, 9202, '2024-05-10', '2024-05-10 11:00:00', '2024-05-10', '2024-05-10 12:00:00', 32817, 2, 2, 'V015', 0, NULL, NULL, NULL, NULL, NULL),
    (16, 8, 9202, '2024-08-20', '2024-08-20 11:00:00', '2024-08-20', '2024-08-20 12:00:00', 32817, 2, 2, 'V016', 0, NULL, NULL, NULL, NULL, NULL),
    (17, 9, 9202, '2024-01-10', '2024-01-10 09:00:00', '2024-01-10', '2024-01-10 10:00:00', 32817, 1, 1, 'V017', 0, NULL, NULL, NULL, NULL, NULL),
    (18, 9, 9202, '2024-03-10', '2024-03-10 09:00:00', '2024-03-10', '2024-03-10 10:00:00', 32817, 1, 1, 'V018', 0, NULL, NULL, NULL, NULL, NULL),
    (19, 9, 9202, '2024-06-10', '2024-06-10 09:00:00', '2024-06-10', '2024-06-10 10:00:00', 32817, 1, 1, 'V019', 0, NULL, NULL, NULL, NULL, NULL),
    (20, 10, 9202, '2024-01-25', '2024-01-25 10:00:00', '2024-01-25', '2024-01-25 11:00:00', 32817, 2, 2, 'V020', 0, NULL, NULL, NULL, NULL, NULL),
    (21, 10, 9203, '2024-04-05', '2024-04-05 18:00:00', '2024-04-05', '2024-04-05 22:00:00', 32817, 3, 3, 'V021', 0, NULL, NULL, NULL, 'Home', NULL),
    (22, 10, 9201, '2024-04-05', '2024-04-05 22:00:00', '2024-04-08', '2024-04-08 11:00:00', 32817, 2, 2, 'V022', 0, 9203, 'Emergency', NULL, 'Home', 21),
    (23, 11, 9202, '2024-01-15', '2024-01-15 15:00:00', '2024-01-15', '2024-01-15 16:00:00', 32817, 3, 3, 'V023', 0, NULL, NULL, NULL, NULL, NULL),
    (24, 11, 9202, '2024-07-20', '2024-07-20 15:00:00', '2024-07-20', '2024-07-20 16:00:00', 32817, 3, 3, 'V024', 0, NULL, NULL, NULL, NULL, NULL),
    (25, 12, 9202, '2024-03-05', '2024-03-05 08:00:00', '2024-03-05', '2024-03-05 09:00:00', 32817, 1, 1, 'V025', 0, NULL, NULL, NULL, NULL, NULL),
    (26, 12, 9202, '2024-06-15', '2024-06-15 08:00:00', '2024-06-15', '2024-06-15 09:00:00', 32817, 1, 1, 'V026', 0, NULL, NULL, NULL, NULL, NULL),
    (27, 13, 9202, '2024-05-01', '2024-05-01 13:00:00', '2024-05-01', '2024-05-01 14:00:00', 32817, 2, 2, 'V027', 0, NULL, NULL, NULL, NULL, NULL),
    (28, 14, 9202, '2024-02-20', '2024-02-20 10:00:00', '2024-02-20', '2024-02-20 11:00:00', 32817, 3, 3, 'V028', 0, NULL, NULL, NULL, NULL, NULL),
    (29, 14, 9202, '2024-05-20', '2024-05-20 10:00:00', '2024-05-20', '2024-05-20 11:00:00', 32817, 3, 3, 'V029', 0, NULL, NULL, NULL, NULL, NULL),
    (30, 14, 9202, '2024-08-20', '2024-08-20 10:00:00', '2024-08-20', '2024-08-20 11:00:00', 32817, 3, 3, 'V030', 0, NULL, NULL, NULL, NULL, NULL),
    (31, 15, 9202, '2024-04-10', '2024-04-10 16:00:00', '2024-04-10', '2024-04-10 17:00:00', 32817, 1, 1, 'V031', 0, NULL, NULL, NULL, NULL, NULL),
    (32, 15, 9202, '2024-07-10', '2024-07-10 16:00:00', '2024-07-10', '2024-07-10 17:00:00', 32817, 1, 1, 'V032', 0, NULL, NULL, NULL, NULL, NULL);

-- =============================================================================
-- 7. POPULATE CONDITIONS (16 condition occurrences)
-- =============================================================================

INSERT INTO CONDITION_OCCURRENCE VALUES
    (1, 1, 201826, '2024-01-15', '2024-01-15 09:30:00', NULL, NULL, 32817, 0, NULL, 1, 1, NULL, 'E11.9', 0, NULL),
    (2, 1, 316866, '2024-01-15', '2024-01-15 09:30:00', NULL, NULL, 32817, 0, NULL, 1, 1, NULL, 'I10', 0, NULL),
    (3, 2, 316866, '2024-02-20', '2024-02-20 10:15:00', NULL, NULL, 32817, 0, NULL, 2, 3, NULL, 'I10', 0, NULL),
    (4, 3, 255848, '2024-05-05', '2024-05-05 20:45:00', '2024-05-12', '2024-05-12 00:00:00', 32817, 0, 'Resolved', 3, 4, NULL, 'J18.9', 0, NULL),
    (5, 4, 201826, '2024-06-12', '2024-06-12 14:15:00', NULL, NULL, 32817, 0, NULL, 1, 5, NULL, 'E11.9', 0, NULL),
    (6, 4, 77670, '2024-03-10', '2024-03-10 14:15:00', '2024-03-10', '2024-03-10 14:15:00', 32817, 0, 'Resolved', 1, 2, NULL, 'R07.9', 0, NULL),
    (7, 5, 255848, '2024-02-10', '2024-02-10 10:15:00', NULL, NULL, 32817, 0, NULL, 2, 6, NULL, 'J45.9', 0, NULL),
    (8, 5, 255848, '2024-08-03', '2024-08-03 22:15:00', '2024-08-10', '2024-08-10 00:00:00', 32817, 0, 'Resolved', 3, 8, NULL, 'J45.9', 0, NULL),
    (9, 6, 201826, '2024-01-20', '2024-01-20 09:15:00', NULL, NULL, 32817, 0, NULL, 1, 9, NULL, 'E11.9', 0, NULL),
    (10, 6, 316866, '2024-01-20', '2024-01-20 09:15:00', NULL, NULL, 32817, 0, NULL, 1, 9, NULL, 'I10', 0, NULL),
    (11, 6, 77670, '2024-07-10', '2024-07-10 16:15:00', '2024-07-10', '2024-07-10 16:15:00', 32817, 0, 'Resolved', 1, 11, NULL, 'R07.9', 0, NULL),
    (12, 8, 201826, '2024-02-05', '2024-02-05 11:15:00', NULL, NULL, 32817, 0, NULL, 2, 14, NULL, 'E11.9', 0, NULL),
    (13, 8, 316866, '2024-02-05', '2024-02-05 11:15:00', NULL, NULL, 32817, 0, NULL, 2, 14, NULL, 'I10', 0, NULL),
    (14, 10, 255848, '2024-01-25', '2024-01-25 10:15:00', NULL, NULL, 32817, 0, NULL, 2, 20, NULL, 'J44.9', 0, NULL),
    (15, 10, 255848, '2024-04-05', '2024-04-05 18:15:00', '2024-04-08', '2024-04-08 11:00:00', 32817, 0, 'Resolved', 3, 21, NULL, 'J44.1', 0, NULL),
    (16, 12, 316866, '2024-03-05', '2024-03-05 08:15:00', NULL, NULL, 32817, 0, NULL, 1, 25, NULL, 'I10', 0, NULL);

-- =============================================================================
-- 8. POPULATE MEDICATIONS (15 drug exposures)
-- =============================================================================

INSERT INTO DRUG_EXPOSURE VALUES
    (1, 1, 1503297, '2024-01-15', '2024-01-15 09:45:00', '2024-07-15', '2024-07-15 09:45:00', NULL, 32817, NULL, 3, 180, 180, 'Take 500mg twice daily with meals', 0, NULL, 1, 1, NULL, 'Metformin 500mg', 0, 'Oral', NULL),
    (2, 1, 1308216, '2024-01-15', '2024-01-15 09:45:00', '2024-07-15', '2024-07-15 09:45:00', NULL, 32817, NULL, 3, 90, 90, 'Take 10mg once daily', 0, NULL, 1, 1, NULL, 'Lisinopril 10mg', 0, 'Oral', NULL),
    (3, 2, 1308216, '2024-02-20', '2024-02-20 10:30:00', '2024-05-20', '2024-05-20 10:30:00', NULL, 32817, NULL, 2, 90, 90, 'Take 20mg once daily', 0, NULL, 2, 3, NULL, 'Lisinopril 20mg', 0, 'Oral', NULL),
    (4, 3, 1136980, '2024-05-05', '2024-05-05 21:00:00', '2024-05-12', '2024-05-12 21:00:00', NULL, 32817, NULL, 0, 1, 7, 'Inhale 2 puffs every 4 hours as needed', 0, NULL, 3, 4, NULL, 'Albuterol inhaler', 0, 'Inhalation', NULL),
    (5, 4, 1503297, '2024-06-12', '2024-06-12 14:30:00', '2024-12-12', '2024-12-12 14:30:00', NULL, 32817, NULL, 1, 180, 180, 'Take 1000mg twice daily', 0, NULL, 1, 5, NULL, 'Metformin 1000mg', 0, 'Oral', NULL),
    (6, 4, 1112807, '2024-06-12', '2024-06-12 14:30:00', '2024-12-12', '2024-12-12 14:30:00', NULL, 32817, NULL, 1, 90, 90, 'Take 40mg once daily at bedtime', 0, NULL, 1, 5, NULL, 'Atorvastatin 40mg', 0, 'Oral', NULL),
    (7, 5, 1136980, '2024-02-10', '2024-02-10 10:30:00', '2024-08-10', '2024-08-10 10:30:00', NULL, 32817, NULL, 2, 1, 180, 'Inhale 2 puffs twice daily', 0, NULL, 2, 6, NULL, 'Albuterol inhaler', 0, 'Inhalation', NULL),
    (8, 6, 1503297, '2024-01-20', '2024-01-20 09:30:00', '2024-07-20', '2024-07-20 09:30:00', NULL, 32817, NULL, 3, 180, 180, 'Take 1000mg twice daily', 0, NULL, 1, 9, NULL, 'Metformin 1000mg', 0, 'Oral', NULL),
    (9, 6, 1308216, '2024-01-20', '2024-01-20 09:30:00', '2024-07-20', '2024-07-20 09:30:00', NULL, 32817, NULL, 3, 90, 180, 'Take 20mg once daily', 0, NULL, 1, 9, NULL, 'Lisinopril 20mg', 0, 'Oral', NULL),
    (10, 6, 1112807, '2024-01-20', '2024-01-20 09:30:00', '2024-07-20', '2024-07-20 09:30:00', NULL, 32817, NULL, 3, 90, 180, 'Take 40mg once daily', 0, NULL, 1, 9, NULL, 'Atorvastatin 40mg', 0, 'Oral', NULL),
    (11, 8, 1503297, '2024-02-05', '2024-02-05 11:30:00', '2024-08-05', '2024-08-05 11:30:00', NULL, 32817, NULL, 2, 180, 180, 'Take 850mg twice daily', 0, NULL, 2, 14, NULL, 'Metformin 850mg', 0, 'Oral', NULL),
    (12, 8, 1308216, '2024-02-05', '2024-02-05 11:30:00', '2024-08-05', '2024-08-05 11:30:00', NULL, 32817, NULL, 2, 90, 180, 'Take 10mg once daily', 0, NULL, 2, 14, NULL, 'Lisinopril 10mg', 0, 'Oral', NULL),
    (13, 10, 1136980, '2024-01-25', '2024-01-25 10:30:00', '2024-07-25', '2024-07-25 10:30:00', NULL, 32817, NULL, 2, 1, 180, 'Inhale 2 puffs every 4-6 hours as needed', 0, NULL, 2, 20, NULL, 'Albuterol inhaler', 0, 'Inhalation', NULL),
    (14, 12, 1308216, '2024-03-05', '2024-03-05 08:30:00', '2024-09-05', '2024-09-05 08:30:00', NULL, 32817, NULL, 2, 90, 180, 'Take 20mg once daily', 0, NULL, 1, 25, NULL, 'Lisinopril 20mg', 0, 'Oral', NULL),
    (15, 12, 1112807, '2024-03-05', '2024-03-05 08:30:00', '2024-09-05', '2024-09-05 08:30:00', NULL, 32817, NULL, 2, 90, 180, 'Take 80mg once daily', 0, NULL, 1, 25, NULL, 'Atorvastatin 80mg', 0, 'Oral', NULL);

-- =============================================================================
-- 9. POPULATE PROCEDURES (18 procedure occurrences)
-- =============================================================================

INSERT INTO PROCEDURE_OCCURRENCE VALUES
    (1, 1, 4305964, '2024-01-15', '2024-01-15 09:15:00', NULL, NULL, 32817, NULL, NULL, 1, 1, NULL, 'BP Check', 0, NULL),
    (2, 1, 2108897, '2024-03-10', '2024-03-10 15:00:00', NULL, NULL, 32817, NULL, NULL, 1, 2, NULL, 'Chest XR', 0, NULL),
    (3, 1, 4337543, '2024-03-10', '2024-03-10 15:30:00', NULL, NULL, 32817, NULL, NULL, 1, 2, NULL, 'ECG', 0, NULL),
    (4, 2, 4305964, '2024-02-20', '2024-02-20 10:00:00', NULL, NULL, 32817, NULL, NULL, 2, 3, NULL, 'BP Check', 0, NULL),
    (5, 3, 2108897, '2024-05-05', '2024-05-05 21:15:00', NULL, NULL, 32817, NULL, NULL, 3, 4, NULL, 'Chest XR', 0, NULL),
    (6, 4, 4305964, '2024-06-12', '2024-06-12 14:00:00', NULL, NULL, 32817, NULL, NULL, 1, 5, NULL, 'BP Check', 0, NULL),
    (7, 5, 4305964, '2024-02-10', '2024-02-10 10:00:00', NULL, NULL, 32817, NULL, NULL, 2, 6, NULL, 'BP Check', 0, NULL),
    (8, 5, 2108897, '2024-08-03', '2024-08-03 22:30:00', NULL, NULL, 32817, NULL, NULL, 3, 8, NULL, 'Chest XR', 0, NULL),
    (9, 6, 4305964, '2024-01-20', '2024-01-20 09:00:00', NULL, NULL, 32817, NULL, NULL, 1, 9, NULL, 'BP Check', 0, NULL),
    (10, 6, 4337543, '2024-07-10', '2024-07-10 16:30:00', NULL, NULL, 32817, NULL, NULL, 1, 11, NULL, 'ECG', 0, NULL),
    (11, 6, 2108897, '2024-07-10', '2024-07-10 17:00:00', NULL, NULL, 32817, NULL, NULL, 1, 11, NULL, 'Chest XR', 0, NULL),
    (12, 8, 4305964, '2024-02-05', '2024-02-05 11:00:00', NULL, NULL, 32817, NULL, NULL, 2, 14, NULL, 'BP Check', 0, NULL),
    (13, 8, 4305964, '2024-05-10', '2024-05-10 11:00:00', NULL, NULL, 32817, NULL, NULL, 2, 15, NULL, 'BP Check', 0, NULL),
    (14, 8, 4305964, '2024-08-20', '2024-08-20 11:00:00', NULL, NULL, 32817, NULL, NULL, 2, 16, NULL, 'BP Check', 0, NULL),
    (15, 10, 4305964, '2024-01-25', '2024-01-25 10:00:00', NULL, NULL, 32817, NULL, NULL, 2, 20, NULL, 'BP Check', 0, NULL),
    (16, 10, 2108897, '2024-04-05', '2024-04-05 18:30:00', NULL, NULL, 32817, NULL, NULL, 3, 21, NULL, 'Chest XR', 0, NULL),
    (17, 12, 4305964, '2024-03-05', '2024-03-05 08:00:00', NULL, NULL, 32817, NULL, NULL, 1, 25, NULL, 'BP Check', 0, NULL),
    (18, 12, 4337543, '2024-03-05', '2024-03-05 08:30:00', NULL, NULL, 32817, NULL, NULL, 1, 25, NULL, 'ECG', 0, NULL);

-- =============================================================================
-- 10. POPULATE MEASUREMENTS (45 measurements - labs and vitals)
-- =============================================================================

INSERT INTO MEASUREMENT VALUES
    -- Patient 1-4 (initial 12 measurements)
    (1, 1, 3027018, '2024-01-15', '2024-01-15 09:15:00', NULL, 32817, NULL, 145, NULL, 0, 90, 140, 1, 1, NULL, 'SBP', 0, 'mmHg', 0, '145', NULL, NULL),
    (2, 1, 3012888, '2024-01-15', '2024-01-15 09:15:00', NULL, 32817, NULL, 92, NULL, 0, 60, 90, 1, 1, NULL, 'DBP', 0, 'mmHg', 0, '92', NULL, NULL),
    (3, 1, 3004249, '2024-01-15', '2024-01-15 09:30:00', NULL, 32817, NULL, 185, NULL, 0, 70, 100, 1, 1, NULL, 'Glucose', 0, 'mg/dL', 0, '185', NULL, NULL),
    (4, 1, 3004410, '2024-01-15', '2024-01-15 09:30:00', NULL, 32817, NULL, 8.2, NULL, 0, 4.0, 5.6, 1, 1, NULL, 'HbA1c', 0, '%', 0, '8.2', NULL, NULL),
    (5, 2, 3027018, '2024-02-20', '2024-02-20 10:00:00', NULL, 32817, NULL, 156, NULL, 0, 90, 140, 2, 3, NULL, 'SBP', 0, 'mmHg', 0, '156', NULL, NULL),
    (6, 2, 3012888, '2024-02-20', '2024-02-20 10:00:00', NULL, 32817, NULL, 95, NULL, 0, 60, 90, 2, 3, NULL, 'DBP', 0, 'mmHg', 0, '95', NULL, NULL),
    (7, 3, 3025315, '2024-05-05', '2024-05-05 20:30:00', NULL, 32817, NULL, 101.5, NULL, 0, 97.0, 99.0, 3, 4, NULL, 'Temp', 0, 'F', 0, '101.5', NULL, NULL),
    (8, 3, 3013762, '2024-05-05', '2024-05-05 20:30:00', NULL, 32817, NULL, 110, NULL, 0, 60, 100, 3, 4, NULL, 'HR', 0, 'bpm', 0, '110', NULL, NULL),
    (9, 4, 3027018, '2024-06-12', '2024-06-12 14:00:00', NULL, 32817, NULL, 138, NULL, 0, 90, 140, 1, 5, NULL, 'SBP', 0, 'mmHg', 0, '138', NULL, NULL),
    (10, 4, 3012888, '2024-06-12', '2024-06-12 14:00:00', NULL, 32817, NULL, 85, NULL, 0, 60, 90, 1, 5, NULL, 'DBP', 0, 'mmHg', 0, '85', NULL, NULL),
    (11, 4, 3004249, '2024-06-12', '2024-06-12 14:15:00', NULL, 32817, NULL, 165, NULL, 0, 70, 100, 1, 5, NULL, 'Glucose', 0, 'mg/dL', 0, '165', NULL, NULL),
    (12, 4, 3004410, '2024-06-12', '2024-06-12 14:15:00', NULL, 32817, NULL, 7.8, NULL, 0, 4.0, 5.6, 1, 5, NULL, 'HbA1c', 0, '%', 0, '7.8', NULL, NULL),
    -- Patient 5-12 (additional 33 measurements)
    (13, 5, 3027018, '2024-02-10', '2024-02-10 10:00:00', NULL, 32817, NULL, 118, NULL, 0, 90, 140, 2, 6, NULL, 'SBP', 0, 'mmHg', 0, '118', NULL, NULL),
    (14, 5, 3012888, '2024-02-10', '2024-02-10 10:00:00', NULL, 32817, NULL, 78, NULL, 0, 60, 90, 2, 6, NULL, 'DBP', 0, 'mmHg', 0, '78', NULL, NULL),
    (15, 5, 3013762, '2024-08-03', '2024-08-03 22:00:00', NULL, 32817, NULL, 105, NULL, 0, 60, 100, 3, 8, NULL, 'HR', 0, 'bpm', 0, '105', NULL, NULL),
    (16, 6, 3027018, '2024-01-20', '2024-01-20 09:00:00', NULL, 32817, NULL, 158, NULL, 0, 90, 140, 1, 9, NULL, 'SBP', 0, 'mmHg', 0, '158', NULL, NULL),
    (17, 6, 3012888, '2024-01-20', '2024-01-20 09:00:00', NULL, 32817, NULL, 94, NULL, 0, 60, 90, 1, 9, NULL, 'DBP', 0, 'mmHg', 0, '94', NULL, NULL),
    (18, 6, 3004249, '2024-01-20', '2024-01-20 09:15:00', NULL, 32817, NULL, 195, NULL, 0, 70, 100, 1, 9, NULL, 'Glucose', 0, 'mg/dL', 0, '195', NULL, NULL),
    (19, 6, 3004410, '2024-01-20', '2024-01-20 09:15:00', NULL, 32817, NULL, 8.5, NULL, 0, 4.0, 5.6, 1, 9, NULL, 'HbA1c', 0, '%', 0, '8.5', NULL, NULL),
    (20, 6, 3027018, '2024-04-15', '2024-04-15 09:00:00', NULL, 32817, NULL, 152, NULL, 0, 90, 140, 1, 10, NULL, 'SBP', 0, 'mmHg', 0, '152', NULL, NULL),
    (21, 6, 3012888, '2024-04-15', '2024-04-15 09:00:00', NULL, 32817, NULL, 92, NULL, 0, 60, 90, 1, 10, NULL, 'DBP', 0, 'mmHg', 0, '92', NULL, NULL),
    (22, 6, 3004249, '2024-04-15', '2024-04-15 09:15:00', NULL, 32817, NULL, 178, NULL, 0, 70, 100, 1, 10, NULL, 'Glucose', 0, 'mg/dL', 0, '178', NULL, NULL),
    (23, 6, 3004410, '2024-04-15', '2024-04-15 09:15:00', NULL, 32817, NULL, 8.0, NULL, 0, 4.0, 5.6, 1, 10, NULL, 'HbA1c', 0, '%', 0, '8.0', NULL, NULL),
    (24, 7, 3027018, '2024-03-01', '2024-03-01 10:00:00', NULL, 32817, NULL, 112, NULL, 0, 90, 140, 3, 12, NULL, 'SBP', 0, 'mmHg', 0, '112', NULL, NULL),
    (25, 7, 3012888, '2024-03-01', '2024-03-01 10:00:00', NULL, 32817, NULL, 72, NULL, 0, 60, 90, 3, 12, NULL, 'DBP', 0, 'mmHg', 0, '72', NULL, NULL),
    (26, 8, 3027018, '2024-02-05', '2024-02-05 11:00:00', NULL, 32817, NULL, 142, NULL, 0, 90, 140, 2, 14, NULL, 'SBP', 0, 'mmHg', 0, '142', NULL, NULL),
    (27, 8, 3012888, '2024-02-05', '2024-02-05 11:00:00', NULL, 32817, NULL, 88, NULL, 0, 60, 90, 2, 14, NULL, 'DBP', 0, 'mmHg', 0, '88', NULL, NULL),
    (28, 8, 3004249, '2024-02-05', '2024-02-05 11:15:00', NULL, 32817, NULL, 168, NULL, 0, 70, 100, 2, 14, NULL, 'Glucose', 0, 'mg/dL', 0, '168', NULL, NULL),
    (29, 8, 3004410, '2024-02-05', '2024-02-05 11:15:00', NULL, 32817, NULL, 7.5, NULL, 0, 4.0, 5.6, 2, 14, NULL, 'HbA1c', 0, '%', 0, '7.5', NULL, NULL),
    (30, 8, 3027018, '2024-05-10', '2024-05-10 11:00:00', NULL, 32817, NULL, 138, NULL, 0, 90, 140, 2, 15, NULL, 'SBP', 0, 'mmHg', 0, '138', NULL, NULL),
    (31, 8, 3012888, '2024-05-10', '2024-05-10 11:00:00', NULL, 32817, NULL, 86, NULL, 0, 60, 90, 2, 15, NULL, 'DBP', 0, 'mmHg', 0, '86', NULL, NULL),
    (32, 8, 3004249, '2024-05-10', '2024-05-10 11:15:00', NULL, 32817, NULL, 155, NULL, 0, 70, 100, 2, 15, NULL, 'Glucose', 0, 'mg/dL', 0, '155', NULL, NULL),
    (33, 8, 3004410, '2024-05-10', '2024-05-10 11:15:00', NULL, 32817, NULL, 7.1, NULL, 0, 4.0, 5.6, 2, 15, NULL, 'HbA1c', 0, '%', 0, '7.1', NULL, NULL),
    (34, 8, 3027018, '2024-08-20', '2024-08-20 11:00:00', NULL, 32817, NULL, 135, NULL, 0, 90, 140, 2, 16, NULL, 'SBP', 0, 'mmHg', 0, '135', NULL, NULL),
    (35, 8, 3012888, '2024-08-20', '2024-08-20 11:00:00', NULL, 32817, NULL, 84, NULL, 0, 60, 90, 2, 16, NULL, 'DBP', 0, 'mmHg', 0, '84', NULL, NULL),
    (36, 8, 3004249, '2024-08-20', '2024-08-20 11:15:00', NULL, 32817, NULL, 142, NULL, 0, 70, 100, 2, 16, NULL, 'Glucose', 0, 'mg/dL', 0, '142', NULL, NULL),
    (37, 8, 3004410, '2024-08-20', '2024-08-20 11:15:00', NULL, 32817, NULL, 6.8, NULL, 0, 4.0, 5.6, 2, 16, NULL, 'HbA1c', 0, '%', 0, '6.8', NULL, NULL),
    (38, 10, 3027018, '2024-01-25', '2024-01-25 10:00:00', NULL, 32817, NULL, 148, NULL, 0, 90, 140, 2, 20, NULL, 'SBP', 0, 'mmHg', 0, '148', NULL, NULL),
    (39, 10, 3012888, '2024-01-25', '2024-01-25 10:00:00', NULL, 32817, NULL, 90, NULL, 0, 60, 90, 2, 20, NULL, 'DBP', 0, 'mmHg', 0, '90', NULL, NULL),
    (40, 10, 3013762, '2024-04-05', '2024-04-05 18:00:00', NULL, 32817, NULL, 115, NULL, 0, 60, 100, 3, 21, NULL, 'HR', 0, 'bpm', 0, '115', NULL, NULL),
    (41, 10, 3025315, '2024-04-05', '2024-04-05 18:00:00', NULL, 32817, NULL, 99.8, NULL, 0, 97.0, 99.0, 3, 21, NULL, 'Temp', 0, 'F', 0, '99.8', NULL, NULL),
    (42, 12, 3027018, '2024-03-05', '2024-03-05 08:00:00', NULL, 32817, NULL, 155, NULL, 0, 90, 140, 1, 25, NULL, 'SBP', 0, 'mmHg', 0, '155', NULL, NULL),
    (43, 12, 3012888, '2024-03-05', '2024-03-05 08:00:00', NULL, 32817, NULL, 95, NULL, 0, 60, 90, 1, 25, NULL, 'DBP', 0, 'mmHg', 0, '95', NULL, NULL),
    (44, 12, 3027018, '2024-06-15', '2024-06-15 08:00:00', NULL, 32817, NULL, 145, NULL, 0, 90, 140, 1, 26, NULL, 'SBP', 0, 'mmHg', 0, '145', NULL, NULL),
    (45, 12, 3012888, '2024-06-15', '2024-06-15 08:00:00', NULL, 32817, NULL, 90, NULL, 0, 60, 90, 1, 26, NULL, 'DBP', 0, 'mmHg', 0, '90', NULL, NULL);

-- =============================================================================
-- 11. ADD PRIMARY KEYS
-- =============================================================================

ALTER TABLE VOCABULARY ADD PRIMARY KEY (vocabulary_id);
ALTER TABLE DOMAIN ADD PRIMARY KEY (domain_id);
ALTER TABLE CONCEPT ADD PRIMARY KEY (concept_id);
ALTER TABLE LOCATION ADD PRIMARY KEY (location_id);
ALTER TABLE CARE_SITE ADD PRIMARY KEY (care_site_id);
ALTER TABLE PROVIDER ADD PRIMARY KEY (provider_id);
ALTER TABLE PERSON ADD PRIMARY KEY (person_id);
ALTER TABLE OBSERVATION_PERIOD ADD PRIMARY KEY (observation_period_id);
ALTER TABLE VISIT_OCCURRENCE ADD PRIMARY KEY (visit_occurrence_id);
ALTER TABLE CONDITION_OCCURRENCE ADD PRIMARY KEY (condition_occurrence_id);
ALTER TABLE DRUG_EXPOSURE ADD PRIMARY KEY (drug_exposure_id);
ALTER TABLE PROCEDURE_OCCURRENCE ADD PRIMARY KEY (procedure_occurrence_id);
ALTER TABLE MEASUREMENT ADD PRIMARY KEY (measurement_id);

-- =============================================================================
-- 12. VERIFICATION - SUMMARY STATISTICS
-- =============================================================================

SELECT 'Total Patients' as metric, COUNT(*) as count FROM PERSON
UNION ALL
SELECT 'Total Visits', COUNT(*) FROM VISIT_OCCURRENCE
UNION ALL
SELECT 'Total Conditions', COUNT(*) FROM CONDITION_OCCURRENCE
UNION ALL
SELECT 'Total Drug Exposures', COUNT(*) FROM DRUG_EXPOSURE
UNION ALL
SELECT 'Total Procedures', COUNT(*) FROM PROCEDURE_OCCURRENCE
UNION ALL
SELECT 'Total Measurements', COUNT(*) FROM MEASUREMENT;

-- Patient summary with counts
SELECT 
    p.person_id,
    CASE p.gender_concept_id WHEN 8507 THEN 'M' ELSE 'F' END as gender,
    YEAR(CURRENT_DATE) - p.year_of_birth as age,
    COUNT(DISTINCT v.visit_occurrence_id) as visit_count,
    COUNT(DISTINCT co.condition_occurrence_id) as condition_count,
    COUNT(DISTINCT de.drug_exposure_id) as medication_count
FROM PERSON p
LEFT JOIN VISIT_OCCURRENCE v ON p.person_id = v.person_id
LEFT JOIN CONDITION_OCCURRENCE co ON p.person_id = co.person_id
LEFT JOIN DRUG_EXPOSURE de ON p.person_id = de.person_id
GROUP BY p.person_id, p.gender_concept_id, p.year_of_birth
ORDER BY p.person_id;

SELECT 'OMOP CDM Sample Data Loaded Successfully!' as status;

-- =============================================================================
-- EXAMPLE QUERIES (commented out - uncomment to run)
-- =============================================================================

/*
-- Patient demographics with their conditions
SELECT 
    p.person_id,
    CASE p.gender_concept_id WHEN 8507 THEN 'Male' WHEN 8532 THEN 'Female' END as gender,
    YEAR(CURRENT_DATE) - p.year_of_birth as age,
    c.concept_name as condition,
    co.condition_start_date
FROM PERSON p
JOIN CONDITION_OCCURRENCE co ON p.person_id = co.person_id
JOIN CONCEPT c ON co.condition_concept_id = c.concept_id
ORDER BY p.person_id, co.condition_start_date;

-- Patients with diabetes and their medications
SELECT 
    p.person_id,
    p.year_of_birth,
    cond.concept_name as condition,
    drug.concept_name as medication,
    de.drug_exposure_start_date,
    de.days_supply,
    de.sig
FROM PERSON p
JOIN CONDITION_OCCURRENCE co ON p.person_id = co.person_id
JOIN CONCEPT cond ON co.condition_concept_id = cond.concept_id
JOIN DRUG_EXPOSURE de ON p.person_id = de.person_id
JOIN CONCEPT drug ON de.drug_concept_id = drug.concept_id
WHERE cond.concept_name LIKE '%diabetes%'
ORDER BY p.person_id;

-- Blood pressure measurements by patient
SELECT 
    p.person_id,
    v.visit_start_date,
    MAX(CASE WHEN m.measurement_concept_id = 3027018 THEN m.value_as_number END) as systolic_bp,
    MAX(CASE WHEN m.measurement_concept_id = 3012888 THEN m.value_as_number END) as diastolic_bp
FROM PERSON p
JOIN VISIT_OCCURRENCE v ON p.person_id = v.person_id
JOIN MEASUREMENT m ON v.visit_occurrence_id = m.visit_occurrence_id
WHERE m.measurement_concept_id IN (3027018, 3012888)
GROUP BY p.person_id, v.visit_start_date
ORDER BY p.person_id, v.visit_start_date;
*/
