# Contributing to OMOP Semantic

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## Development Setup

1. Clone the repository
2. Install dependencies: `pip install -r requirements.txt`
3. Configure Databricks workspace access
4. Set up pre-commit hooks (optional but recommended)

## Coding Standards

We follow the guidelines defined in `.cursorrules`:

- **Python**: PEP 8, type hints, Google-style docstrings
- **SQL**: Uppercase keywords, snake_case identifiers
- **Line length**: 100 characters for Python, 120 for SQL

## Branch Strategy

- `main`: Production-ready code
- `develop`: Integration branch for features
- `feature/*`: New features or enhancements
- `bugfix/*`: Bug fixes
- `hotfix/*`: Urgent production fixes

## Pull Request Process

1. Create a feature branch from `develop`
2. Make your changes following coding standards
3. Write/update tests for your changes
4. Update documentation as needed
5. Ensure all tests pass
6. Submit PR with clear description
7. Address review feedback

## Testing

All contributions must include appropriate tests:

```bash
# Run tests locally
pytest tests/

# Run with coverage
pytest --cov=src tests/

# Run specific test suite
pytest tests/unit/
```

## Documentation

Update documentation for:
- New features or functionality
- API changes
- Configuration changes
- Architecture modifications

## Code Review

All submissions require code review:
- At least one approval from maintainers
- All CI checks must pass
- No merge conflicts
- Documentation updated

## Questions?

Feel free to open an issue for questions or discussions!
