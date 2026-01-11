#!/bin/bash
# =============================================================================
# OMOP Semantic Layer - Master Deployment Script
# =============================================================================
# This script deploys the complete OMOP Semantic Layer infrastructure:
# 1. Snowflake connection and foreign catalog (Terraform)
# 2. Semantic layer metric views (Databricks Asset Bundles)
# 3. Genie Space for natural language queries (Python API)
#
# Usage:
#   ./deploy.sh [--env ENV] [--component COMPONENT]
#
# Arguments:
#   --env         Environment (dev|prod), default: dev
#   --component   Specific component (connection|views|genie|all), default: all
#
# Prerequisites:
#   - Terraform installed
#   - Databricks CLI installed and configured
#   - Python 3 with requests library
#   - Environment variables or .env file with credentials
# =============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
ENV="dev"
COMPONENT="all"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --env)
            ENV="$2"
            shift 2
            ;;
        --component)
            COMPONENT="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [--env ENV] [--component COMPONENT]"
            echo ""
            echo "Options:"
            echo "  --env         Environment (dev|prod), default: dev"
            echo "  --component   Component (connection|views|genie|all), default: all"
            echo ""
            echo "Components:"
            echo "  connection    Deploy Snowflake connection and catalog"
            echo "  views         Deploy semantic layer metric views"
            echo "  genie         Deploy Genie Space"
            echo "  all           Deploy everything"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Helper functions
print_header() {
    echo -e "${BLUE}================================================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================================================================================${NC}"
}

print_step() {
    echo -e "${GREEN}▶ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Load environment-specific configuration
load_env_config() {
    local env_file="$PROJECT_ROOT/config/$ENV/.env"
    if [ -f "$env_file" ]; then
        print_step "Loading environment configuration: $ENV"
        # shellcheck disable=SC1090
        source "$env_file"
        print_success "Environment loaded"
    else
        print_warning "No environment file found at $env_file"
        print_warning "Using default/environment variables"
    fi
}

# Check prerequisites
check_prerequisites() {
    print_step "Checking prerequisites..."
    
    local missing=0
    
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform not found"
        missing=1
    else
        print_success "Terraform: $(terraform version -json | jq -r '.terraform_version')"
    fi
    
    if ! command -v databricks &> /dev/null; then
        print_error "Databricks CLI not found"
        missing=1
    else
        print_success "Databricks CLI: $(databricks --version | head -1)"
    fi
    
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 not found"
        missing=1
    else
        print_success "Python: $(python3 --version)"
    fi
    
    if [ $missing -eq 1 ]; then
        print_error "Missing prerequisites. Please install required tools."
        exit 1
    fi
}

# Deploy Snowflake connection and catalog
deploy_connection() {
    print_header "STEP 1: DEPLOY SNOWFLAKE CONNECTION & CATALOG"
    
    cd "$PROJECT_ROOT/deployment/terraform/connections"
    
    print_step "Initializing Terraform..."
    terraform init
    
    print_step "Planning Terraform deployment..."
    terraform plan -out=tfplan
    
    print_step "Applying Terraform configuration..."
    terraform apply tfplan
    
    print_success "Snowflake connection and catalog deployed"
    
    cd "$PROJECT_ROOT"
}

# Deploy semantic layer metric views
deploy_views() {
    print_header "STEP 2: DEPLOY SEMANTIC LAYER METRIC VIEWS"
    
    print_warning "Metric views must be deployed manually or via DABs"
    print_warning "Due to Unity Catalog requirements, views need compute environment"
    echo ""
    
    print_step "Option 1: Deploy via Databricks Asset Bundles"
    echo "  cd deployment/dabs/semantic_layer"
    echo "  databricks bundle deploy --target $ENV"
    echo "  databricks bundle run deploy_metric_views --target $ENV"
    echo ""
    
    print_step "Option 2: Manual deployment in SQL Editor"
    echo "  1. Open: https://[workspace]/sql/editor"
    echo "  2. Copy contents of: sql/ddl/deploy_metric_views.sql"
    echo "  3. Set variables at top of file"
    echo "  4. Execute the SQL"
    echo ""
    
    read -p "Have you deployed the metric views? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Skipping metric views deployment"
        return 1
    fi
    
    print_success "Metric views deployment confirmed"
}

# Deploy Genie Space
deploy_genie() {
    print_header "STEP 3: DEPLOY GENIE SPACE"
    
    print_step "Deploying Genie Space for natural language queries..."
    
    # Check for required environment variables
    if [ -z "$GENIE_WAREHOUSE_ID" ]; then
        print_error "GENIE_WAREHOUSE_ID not set"
        print_step "Get warehouse ID with: databricks sql warehouses list"
        read -p "Enter SQL Warehouse ID: " GENIE_WAREHOUSE_ID
    fi
    
    if [ -z "$DATABRICKS_TOKEN" ]; then
        print_error "DATABRICKS_TOKEN not set"
        read -sp "Enter Databricks Token: " DATABRICKS_TOKEN
        echo
    fi
    
    export DATABRICKS_TOKEN
    
    cd "$PROJECT_ROOT/resources/genie"
    
    python3 deploy_genie_space.py \
        --name "OMOP Semantic Layer - $ENV" \
        --warehouse-id "$GENIE_WAREHOUSE_ID"
    
    print_success "Genie Space deployed"
    
    cd "$PROJECT_ROOT"
}

# Main deployment flow
main() {
    print_header "OMOP SEMANTIC LAYER - DEPLOYMENT"
    echo "Environment: $ENV"
    echo "Component: $COMPONENT"
    echo ""
    
    # Load configuration
    load_env_config
    
    # Check prerequisites
    check_prerequisites
    echo ""
    
    # Deploy components based on selection
    case $COMPONENT in
        connection)
            deploy_connection
            ;;
        views)
            deploy_views
            ;;
        genie)
            deploy_genie
            ;;
        all)
            deploy_connection
            echo ""
            deploy_views
            echo ""
            deploy_genie
            ;;
        *)
            print_error "Unknown component: $COMPONENT"
            exit 1
            ;;
    esac
    
    echo ""
    print_header "DEPLOYMENT COMPLETE"
    print_success "All components deployed successfully!"
    echo ""
    echo "Next steps:"
    echo "  1. Verify connection in Unity Catalog"
    echo "  2. Test metric views with sample queries"
    echo "  3. Open Genie Space and ask questions"
    echo ""
    echo "Documentation:"
    echo "  - Main README: $PROJECT_ROOT/README.md"
    echo "  - Deployment Guide: $PROJECT_ROOT/docs/setup/DEPLOYMENT.md"
    echo ""
}

# Run main function
main
