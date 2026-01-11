# Foreign Catalog Configuration
#
# This configuration creates a foreign catalog that connects to Snowflake
# via the Databricks connection created above.

# Create the foreign catalog
resource "databricks_catalog" "snowflake" {
  name    = var.catalog_name
  comment = var.catalog_comment
  
  # Reference the connection created above
  connection_name = databricks_connection.snowflake.name
  
  # Snowflake database to map
  options = {
    database = var.snowflake_database
  }
  
  # Dependency ensures connection is created first
  depends_on = [databricks_connection.snowflake]
}

# Output the catalog details
output "catalog_name" {
  description = "The name of the created catalog"
  value       = databricks_catalog.snowflake.name
}

output "catalog_id" {
  description = "The ID of the created catalog"
  value       = databricks_catalog.snowflake.id
}

output "catalog_type" {
  description = "The type of catalog"
  value       = databricks_catalog.snowflake.catalog_type
}
