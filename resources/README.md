# Resources

This directory contains supporting resources for the OMOP Semantic project.

## Structure

- **vocabularies/**: OMOP standardized vocabularies
  - Standard concepts from Athena
  - Custom concept mappings
  - Source-to-concept maps
  
- **samples/**: Sample data for development and testing
  - Small datasets for unit tests
  - Example OMOP CDM data
  - Test fixtures

## OMOP Vocabularies

OMOP vocabularies are downloaded from [Athena](https://athena.ohdsi.org/):
- SNOMED CT
- RxNorm
- LOINC
- ICD-10-CM
- CPT4
- And others...

## Usage

Place downloaded vocabulary CSV files in `/resources/vocabularies/` for:
- Data validation
- Concept mapping
- Standardization processes

⚠️ **Note**: Large vocabulary files should not be committed to git. Add them to `.gitignore` and document download instructions.
