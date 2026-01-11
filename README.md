# OMOP Semantic - Healthcare Data Standardization

A Databricks-based project for implementing OMOP (Observational Medical Outcomes Partnership) Common Data Model for semantic analysis and healthcare data standardization.

## 🏗️ Project Structure

```
omop_semantic/
├── src/                    # Source code
│   ├── etl/               # ETL pipelines (Bronze → Silver → Gold)
│   ├── models/            # Data models and schemas
│   │   └── omop/         # OMOP CDM v5.4 implementations
│   ├── utils/            # Utility functions and helpers
│   └── validation/       # Data quality and validation
├── sql/                   # SQL scripts and queries
│   ├── ddl/              # Table creation scripts
│   ├── dml/              # Data manipulation queries
│   └── analysis/         # Analytical queries
├── notebooks/            # Databricks notebooks
│   ├── exploration/      # Exploratory data analysis
│   ├── etl/              # ETL workflow notebooks
│   └── analysis/         # Analytical notebooks
├── tests/                # Test suites
│   ├── unit/            # Unit tests
│   └── integration/     # Integration tests
├── config/              # Configuration files
│   ├── dev/            # Development environment
│   └── prod/           # Production environment
├── docs/               # Documentation
│   ├── setup/         # Setup and installation guides
│   ├── architecture/  # Architecture and design docs
│   └── user_guide/    # User guides and tutorials
├── resources/          # Additional resources
│   ├── vocabularies/  # OMOP vocabularies and mappings
│   └── samples/       # Sample data and examples
└── deployment/         # Deployment artifacts
    └── dabs/          # Databricks Asset Bundles

.cursorrules            # Cursor AI configuration
.gitignore             # Git ignore patterns
requirements.txt       # Python dependencies
databricks.yml         # Databricks project config
README.md             # This file
```

## 🚀 Quick Start

### Prerequisites
- Databricks workspace access
- Python 3.9+
- Databricks CLI (optional)

### Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/jward-dbx/omop_semantic.git
   cd omop_semantic
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Configure workspace credentials (see `docs/setup/WORKSPACE_SETUP.md`)

## 🏪 Workspaces

### Vending Machine (Development/Sandbox)
- **Alias**: `vending-machine`
- **URL**: https://fe-sandbox-serverless-rde85f.cloud.databricks.com
- **Purpose**: Development, testing, and experimentation

## 🛠️ Development

### MCP Servers
This project is configured with Databricks Managed MCP servers:
- `vending-machine-dbsql` - SQL query execution
- `vending-machine-system-ai` - Python execution and AI functions

### Architecture
We follow the **Medallion Architecture**:
- **Bronze**: Raw, unprocessed data from source systems
- **Silver**: Cleaned, validated, and standardized data
- **Gold**: Aggregated, analysis-ready datasets (OMOP CDM tables)

### OMOP CDM
This project implements **OMOP CDM v5.4** with:
- Standardized clinical vocabularies
- Unified data model for observational healthcare data
- Support for multi-source data integration

## 📝 Contributing

1. Create a feature branch from `main`
2. Make your changes following the project standards (see `.cursorrules`)
3. Write tests for new functionality
4. Update documentation as needed
5. Submit a pull request

## 🔒 Security

- All sensitive credentials are stored securely and excluded from git
- Follow HIPAA compliance guidelines for healthcare data
- Use Databricks secrets for production deployments

## 📚 Documentation

- [Setup Guide](docs/setup/WORKSPACE_SETUP.md) - Workspace configuration
- [MCP Setup](docs/setup/MCP_SETUP.md) - Managed MCP server setup
- [OMOP Implementation](docs/architecture/OMOP_IMPLEMENTATION.md) - OMOP CDM details
- [Deployment Guide](docs/setup/DEPLOYMENT.md) - How to deploy to Databricks

## 📄 License

See LICENSE file for details.

## 🤝 Support

For questions or issues, please contact the project maintainers.

---

*Last updated: January 11, 2026*
