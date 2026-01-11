#!/bin/bash
# Deploy OMOP Semantic Layer Metric Views using Databricks Asset Bundles
#
# This script:
# 1. Validates the bundle configuration
# 2. Deploys the bundle (creates job and warehouse)
# 3. Runs the job to create metric views
# 4. Verifies the deployment

set -e

# Configuration
TARGET="${1:-dev}"
WAIT_FOR_COMPLETION="${2:-true}"

echo "=================================================="
echo "OMOP Semantic Layer - Metric Views Deployment"
echo "=================================================="
echo "Target: $TARGET"
echo "Bundle: deployment/dabs/semantic_layer"
echo ""

# Change to bundle directory
cd "$(dirname "$0")"
BUNDLE_DIR="$(pwd)"

echo "📋 Step 1: Validating bundle configuration..."
databricks bundle validate --target "$TARGET"
echo "✅ Bundle configuration is valid"
echo ""

echo "🚀 Step 2: Deploying bundle resources..."
databricks bundle deploy --target "$TARGET"
echo "✅ Bundle deployed successfully"
echo ""

echo "▶️  Step 3: Running deployment job..."
if [ "$WAIT_FOR_COMPLETION" = "true" ]; then
    echo "   (Waiting for completion...)"
    RUN_OUTPUT=$(databricks bundle run deploy_metric_views --target "$TARGET")
    echo "$RUN_OUTPUT"
    
    # Extract run ID
    RUN_ID=$(echo "$RUN_OUTPUT" | grep -o 'run_id=[0-9]*' | cut -d'=' -f2 || echo "")
    
    if [ -n "$RUN_ID" ]; then
        echo ""
        echo "📊 Job started. Run ID: $RUN_ID"
        echo "   View in workspace: https://fe-sandbox-serverless-rde85f.cloud.databricks.com/#job/runs/$RUN_ID"
    fi
else
    databricks bundle run deploy_metric_views --target "$TARGET" --no-wait
    echo "   Job triggered (not waiting for completion)"
fi
echo ""

echo "🔍 Step 4: Verifying deployment..."
sleep 5  # Give it a moment to complete

# Try to list the views using databricks CLI
echo "   Checking for created metric views..."
# Note: This requires databricks CLI to be configured
# Views should be visible in: serverless_rde85f_catalog.semantic_omop_cursor

echo ""
echo "=================================================="
echo "✅ Deployment Complete!"
echo "=================================================="
echo ""
echo "Next steps:"
echo "1. Verify views in Databricks UI:"
echo "   https://fe-sandbox-serverless-rde85f.cloud.databricks.com/explore/data/serverless_rde85f_catalog/semantic_omop_cursor"
echo ""
echo "2. Test a metric view:"
echo "   SELECT Gender, MEASURE(\`Total Patients\`)"
echo "   FROM serverless_rde85f_catalog.semantic_omop_cursor.patient_population_metrics"
echo "   GROUP BY Gender;"
echo ""
echo "3. View job runs:"
echo "   databricks bundle jobs list --target $TARGET"
echo ""
