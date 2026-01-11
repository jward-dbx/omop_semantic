# Test Suite

This directory contains all test cases for the OMOP Semantic project.

## Structure

- **unit/**: Unit tests for individual functions and classes
  - Test isolated components
  - Fast execution
  - Mock external dependencies
  
- **integration/**: Integration tests for end-to-end workflows
  - Test complete ETL pipelines
  - Validate OMOP CDM constraints
  - Test data quality rules

## Running Tests

```bash
# Run all tests
pytest tests/

# Run unit tests only
pytest tests/unit/

# Run integration tests
pytest tests/integration/

# Run with coverage
pytest --cov=src tests/
```

## Writing Tests

1. Use pytest framework
2. Follow naming convention: `test_*.py`
3. Use fixtures for test data
4. Test both success and failure cases
5. Include docstrings explaining what is tested

## Test Data

- Use sample OMOP data in `/resources/samples/`
- Mock external API calls
- Clean up test data after execution
