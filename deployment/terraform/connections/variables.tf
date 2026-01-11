# Terraform Variables for Snowflake Connection
#
# These variables make the configuration reusable across different
# workspaces and Snowflake instances.

# ============================================================================
# Databricks Configuration
# ============================================================================

variable "databricks_host" {
  description = "Databricks workspace URL"
  type        = string
  # Example: "https://fe-sandbox-serverless-rde85f.cloud.databricks.com"
}

variable "databricks_token" {
  description = "Databricks personal access token or service principal token"
  type        = string
  sensitive   = true
}

# ============================================================================
# Connection Configuration
# ============================================================================

variable "connection_name" {
  description = "Name of the Snowflake connection in Databricks"
  type        = string
  # Example: "conn_sf_ward"
}

variable "connection_comment" {
  description = "Description of the connection"
  type        = string
  default     = "Snowflake connection for federated queries"
}

# ============================================================================
# Snowflake Configuration
# ============================================================================

variable "snowflake_host" {
  description = "Snowflake account hostname"
  type        = string
  # Example: "REA76172.east-us-2.azure.snowflakecomputing.com"
}

variable "snowflake_port" {
  description = "Snowflake connection port"
  type        = string
  default     = "443"
}

variable "snowflake_warehouse" {
  description = "Snowflake warehouse name"
  type        = string
  # Example: "COMPUTE_WH"
}

variable "snowflake_role" {
  description = "Snowflake role to use for the connection"
  type        = string
  # Example: "ICEBERG_READER"
}

variable "use_proxy" {
  description = "Whether to use a proxy for the connection"
  type        = string
  default     = "false"
}

# ============================================================================
# Snowflake Credentials
# ============================================================================

variable "snowflake_username" {
  description = "Snowflake username for authentication"
  type        = string
  # Example: "DATABRICKS_FED_USER"
}

variable "snowflake_password" {
  description = "Snowflake password for authentication"
  type        = string
  sensitive   = true
}

# ============================================================================
# Catalog Configuration
# ============================================================================

variable "catalog_name" {
  description = "Name of the foreign catalog in Databricks"
  type        = string
  # Example: "conn_sf_ward_catalog"
}

variable "catalog_comment" {
  description = "Description of the catalog"
  type        = string
  default     = "Foreign catalog connected to Snowflake"
}

variable "snowflake_database" {
  description = "Snowflake database name to map to the catalog"
  type        = string
  # Example: "OMOP"
}
