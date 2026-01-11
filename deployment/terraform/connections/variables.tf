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
# Secrets Configuration
# ============================================================================

variable "secret_scope" {
  description = "Databricks secret scope containing Snowflake credentials"
  type        = string
  # Example: "snowflake_creds"
}

variable "secret_key_username" {
  description = "Key name for Snowflake username in the secret scope"
  type        = string
  default     = "username"
}

variable "secret_key_password" {
  description = "Key name for Snowflake password in the secret scope"
  type        = string
  default     = "password"
}
