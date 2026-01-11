# Source Code

This directory contains the core application code for the OMOP Semantic project.

## Structure

- **etl/**: ETL pipelines for data ingestion and transformation
  - Follows Medallion Architecture (Bronze → Silver → Gold)
  - Handles data from various source systems
  
- **models/**: Data models and schema definitions
  - **omop/**: OMOP CDM v5.4 table definitions and models
  
- **utils/**: Common utility functions and helpers
  - Reusable functions across the project
  - Logging, configuration, and helper utilities
  
- **validation/**: Data quality and validation rules
  - OMOP CDM constraint validation
  - Data quality checks
  - Referential integrity checks

## Development Guidelines

1. Follow the coding standards defined in `.cursorrules`
2. Write unit tests for all new functions
3. Use type hints and docstrings
4. Keep functions focused and modular
5. Use Databricks best practices

## Usage

Import modules using absolute imports:
```python
from src.etl.bronze import ingest_data
from src.models.omop import Person, Observation
from src.utils.logger import get_logger
```
