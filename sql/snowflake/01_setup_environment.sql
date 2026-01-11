-- =============================================================================
-- Snowflake Environment Setup
-- =============================================================================
-- This script creates the necessary Snowflake objects for OMOP CDM:
--   - Users
--   - Roles
--   - Databases
--   - Schemas
--   - Volumes
--   - Grants
--
-- Usage:
--   Execute this script in Snowflake with appropriate admin privileges
-- =============================================================================

-- ============================================================
-- EXTERNAL VOLUME (Iceberg storage on ADLS)
-- NOTE:
--  - STORAGE_BASE_URL must be a quoted string
--  - Use azure:// (not https://)
--  - Trailing slash is required
-- ============================================================
CREATE OR REPLACE EXTERNAL VOLUME EXVOL_ICEBERG
  STORAGE_LOCATIONS =
    (
      (
        NAME = 'iceberg_location'
        STORAGE_PROVIDER = 'AZURE'
        STORAGE_BASE_URL = 'azure://wardberg.blob.core.windows.net/iceberg2/tables/'
        AZURE_TENANT_ID  = 'bf465dc7-3bc8-4944-b018-092572b5c20d'
      )
    );

-- Use output to approve Azure consent and find the enterprise app
DESC EXTERNAL VOLUME EXVOL_ICEBERG;


-- ============================================================
-- DATABASE & SCHEMA
-- ============================================================
CREATE DATABASE IF NOT EXISTS ICEBERG_ROUND2;

CREATE SCHEMA IF NOT EXISTS ICEBERG_ROUND2.ICEBERG_SCHEMA;


-- ============================================================
-- ICEBERG TABLE (Snowflake-managed)
-- ============================================================
CREATE OR REPLACE ICEBERG TABLE
  ICEBERG_ROUND2.ICEBERG_SCHEMA.ICEBERG_TABLE
  CATALOG = 'SNOWFLAKE'
  EXTERNAL_VOLUME = 'EXVOL_ICEBERG'
  BASE_LOCATION = 'MY_ICEBERG_TABLE'
AS
SELECT *
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CALL_CENTER;


-- ============================================================
-- PROPRIETARY TABLE (for comparison)
-- ============================================================
CREATE OR REPLACE TABLE
  ICEBERG_ROUND2.ICEBERG_SCHEMA.PROP_TABLE
AS
SELECT *
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CALL_CENTER;


-- ============================================================
-- ROLE (Iceberg reader)
-- ============================================================
CREATE ROLE IF NOT EXISTS ICEBERG_READER;


-- ============================================================
-- USER (Federation / Reader)
-- ============================================================
CREATE USER IF NOT EXISTS DATABRICKS_FED_USER
  DEFAULT_ROLE = ICEBERG_READER
  DEFAULT_WAREHOUSE = COMPUTE_WH
  PASSWORD = 'StrongTempPassword123!'
  MUST_CHANGE_PASSWORD = FALSE;


-- ============================================================
-- DATABASE / SCHEMA ACCESS
-- ============================================================
GRANT USAGE ON DATABASE ICEBERG_ROUND2
  TO ROLE ICEBERG_READER;

GRANT USAGE ON SCHEMA ICEBERG_ROUND2.ICEBERG_SCHEMA
  TO ROLE ICEBERG_READER;

GRANT USAGE ON DATABASE OMOP
  TO ROLE ICEBERG_READER;

GRANT USAGE ON SCHEMA OMOP.OMOP
  TO ROLE ICEBERG_READER;
  
GRANT SELECT ON ALL TABLES
  IN SCHEMA OMOP.OMOP
  TO ROLE ICEBERG_READER;

GRANT SELECT ON FUTURE TABLES
  IN SCHEMA OMOP.OMOP
  TO ROLE ICEBERG_READER;



-- ============================================================
-- PROPRIETARY TABLE ACCESS
-- ============================================================
GRANT SELECT ON ALL TABLES
  IN SCHEMA ICEBERG_ROUND2.ICEBERG_SCHEMA
  TO ROLE ICEBERG_READER;

GRANT SELECT ON FUTURE TABLES
  IN SCHEMA ICEBERG_ROUND2.ICEBERG_SCHEMA
  TO ROLE ICEBERG_READER;


-- ============================================================
-- ICEBERG-SPECIFIC ACCESS (critical)
-- ============================================================
GRANT SELECT ON ALL ICEBERG TABLES
  IN SCHEMA ICEBERG_ROUND2.ICEBERG_SCHEMA
  TO ROLE ICEBERG_READER;

GRANT SELECT ON FUTURE ICEBERG TABLES
  IN SCHEMA ICEBERG_ROUND2.ICEBERG_SCHEMA
  TO ROLE ICEBERG_READER;

GRANT USAGE ON EXTERNAL VOLUME EXVOL_ICEBERG
  TO ROLE ICEBERG_READER;


-- ============================================================
-- WAREHOUSE ACCESS
-- ============================================================
GRANT USAGE ON WAREHOUSE COMPUTE_WH
  TO ROLE ICEBERG_READER;


-- ============================================================
-- USER ↔ ROLE BINDING
-- ============================================================
GRANT ROLE ICEBERG_READER
  TO USER DATABRICKS_FED_USER;