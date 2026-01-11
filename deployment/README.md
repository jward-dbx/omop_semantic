# Deployment

This directory contains deployment artifacts and configurations.

## Structure

- **dabs/**: Databricks Asset Bundles
  - Infrastructure as code for Databricks resources
  - Workflows, jobs, and compute configurations
  - Environment-specific overrides

## Databricks Asset Bundles (DABs)

DABs enable version-controlled, repeatable deployments of Databricks resources.

### Usage

```bash
# Validate bundle configuration
databricks bundle validate

# Deploy to development
databricks bundle deploy -t dev

# Deploy to production
databricks bundle deploy -t prod

# Run a job
databricks bundle run my_job_name
```

## Best Practices

1. Use separate configurations for dev/prod
2. Version control all deployment artifacts
3. Test in development before production deployment
4. Use CI/CD pipelines for automated deployments
5. Document deployment dependencies

## Resources

- [Databricks Asset Bundles Documentation](https://docs.databricks.com/dev-tools/bundles/)
