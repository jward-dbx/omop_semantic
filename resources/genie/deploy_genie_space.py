#!/usr/bin/env python3
"""
Deploy OMOP Semantic Layer Genie Space

Creates a Genie space for querying OMOP CDM metric views using natural language.
This script uses the exported configuration from the existing space and creates
a duplicate with a new name.

Usage:
    python deploy_genie_space.py --name "OMOP Semantic Layer - Cursor" --warehouse-id YOUR_WAREHOUSE_ID
"""

import argparse
import json
import os
import requests
import sys
from pathlib import Path


def load_config(config_file):
    """Load the Genie space configuration from file."""
    with open(config_file, 'r') as f:
        return json.load(f)


def create_genie_space(workspace_url, token, display_name, description, 
                       warehouse_id, serialized_space):
    """
    Create a new Genie space.
    
    Args:
        workspace_url: Databricks workspace URL
        token: Access token
        display_name: Name of the Genie space
        description: Description text
        warehouse_id: SQL warehouse ID
        serialized_space: Configuration as JSON string
    
    Returns:
        dict: Response containing space_id
    """
    url = f"{workspace_url}/api/2.0/genie/spaces"
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "display_name": display_name,
        "description": description,
        "warehouse_id": warehouse_id,
        "serialized_space": serialized_space
    }
    
    response = requests.post(url, headers=headers, json=payload)
    response.raise_for_status()
    
    return response.json()


def main():
    parser = argparse.ArgumentParser(
        description="Deploy OMOP Semantic Layer Genie Space"
    )
    parser.add_argument(
        "--name",
        default="OMOP Semantic Layer - Cursor Deployed",
        help="Name for the new Genie space"
    )
    parser.add_argument(
        "--warehouse-id",
        required=True,
        help="SQL warehouse ID"
    )
    parser.add_argument(
        "--workspace-url",
        default="https://fe-sandbox-serverless-rde85f.cloud.databricks.com",
        help="Databricks workspace URL"
    )
    parser.add_argument(
        "--token",
        help="Databricks access token (or set DATABRICKS_TOKEN env var)"
    )
    parser.add_argument(
        "--config-file",
        default="resources/genie/omop_semantic_layer_export.json",
        help="Path to exported Genie space configuration"
    )
    
    args = parser.parse_args()
    
    # Get token from args or environment
    token = args.token or os.getenv('DATABRICKS_TOKEN')
    if not token:
        print("Error: Databricks token required. Provide via --token or DATABRICKS_TOKEN env var")
        return 1
    
    print("=" * 70)
    print("OMOP SEMANTIC LAYER - GENIE SPACE DEPLOYMENT")
    print("=" * 70)
    print()
    
    # Load configuration
    print("[1/3] Loading configuration...")
    config = load_config(args.config_file)
    print(f"  ✓ Loaded from: {args.config_file}")
    print(f"  ✓ Source space: {config['title']}")
    print()
    
    # Prepare for deployment
    print("[2/3] Preparing deployment...")
    serialized_space = config['serialized_space']
    
    # Parse to show stats
    parsed = json.loads(serialized_space)
    metric_views = parsed.get('data_sources', {}).get('metric_views', [])
    sample_questions = parsed.get('config', {}).get('sample_questions', [])
    
    print(f"  ✓ Metric Views: {len(metric_views)}")
    print(f"  ✓ Sample Questions: {len(sample_questions)}")
    print(f"  ✓ Target Warehouse: {args.warehouse_id}")
    print()
    
    # Deploy
    print("[3/3] Creating Genie space...")
    try:
        result = create_genie_space(
            args.workspace_url,
            token,
            args.name,
            config['description'],
            args.warehouse_id,
            serialized_space
        )
        
        new_space_id = result.get('space_id')
        
        print()
        print("=" * 70)
        print("✅ DEPLOYMENT SUCCESSFUL!")
        print("=" * 70)
        print(f"Space ID: {new_space_id}")
        print(f"Name: {args.name}")
        print(f"URL: {args.workspace_url}/genie/rooms/{new_space_id}")
        print()
        print("Next Steps:")
        print("  1. Open the URL above to access your Genie space")
        print("  2. Try one of the sample questions")
        print("  3. Ask your own natural language questions")
        print("=" * 70)
        
        return 0
        
    except requests.exceptions.HTTPError as e:
        print()
        print("=" * 70)
        print("❌ DEPLOYMENT FAILED")
        print("=" * 70)
        print(f"Error: {e}")
        print(f"Response: {e.response.text}")
        print("=" * 70)
        return 1
    except Exception as e:
        print()
        print("=" * 70)
        print("❌ DEPLOYMENT FAILED")
        print("=" * 70)
        print(f"Error: {str(e)}")
        print("=" * 70)
        return 1


if __name__ == "__main__":
    sys.exit(main())
