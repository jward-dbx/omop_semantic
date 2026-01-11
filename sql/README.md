# SQL Scripts

This directory contains SQL scripts for database operations.

## Structure

- **ddl/**: Data Definition Language scripts
  - Table creation scripts for OMOP CDM tables
  - View definitions
  - Index creation
  
- **dml/**: Data Manipulation Language scripts
  - Data loading scripts
  - Update and maintenance scripts
  
- **analysis/**: Analytical queries
  - Business intelligence queries
  - Reporting queries
  - Data exploration queries

## Naming Conventions

- Use descriptive names: `create_person_table.sql`, `load_observations.sql`
- Prefix with numbers for execution order: `01_create_schemas.sql`, `02_create_tables.sql`
- Use underscores to separate words

## Best Practices

1. Use Unity Catalog three-level namespace: `catalog.schema.table`
2. Include comments explaining complex logic
3. Use uppercase for SQL keywords
4. Use snake_case for identifiers
5. Include rollback scripts where appropriate
