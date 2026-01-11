# Snowflake Connection - Terraform Configuration
#
# This configuration creates a Snowflake connection in Databricks Unity Catalog.
# It uses variables for all environment-specific values to enable deployment
# across different workspaces and Snowflake instances.

terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.0"
    }
  }
}

# Databricks provider configuration
provider "databricks" {
  host  = var.databricks_host
  token = var.databricks_token
}

# Create the Snowflake connection
resource "databricks_connection" "snowflake" {
  name            = var.connection_name
  connection_type = "SNOWFLAKE"
  comment         = var.connection_comment

  options = {
    host          = var.snowflake_host
    port          = var.snowflake_port
    sfWarehouse   = var.snowflake_warehouse
    sfRole        = var.snowflake_role
    use_proxy     = var.use_proxy
  }

  # Credentials are managed via Databricks secrets
  # Reference the secret scope and keys
  properties = {
    user     = "{{secrets/${var.secret_scope}/${var.secret_key_username}}}"
    password = "{{secrets/${var.secret_scope}/${var.secret_key_password}}}"
  }
}

# Output the connection details
output "connection_name" {
  description = "The name of the created connection"
  value       = databricks_connection.snowflake.name
}

output "connection_id" {
  description = "The ID of the created connection"
  value       = databricks_connection.snowflake.id
}

output "connection_url" {
  description = "The JDBC URL of the connection"
  value       = "jdbc://${var.snowflake_host}:${var.snowflake_port}/"
}
