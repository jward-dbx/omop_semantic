#!/usr/bin/env python3
"""
Deploy Databricks Semantic Layer Metric Views

This script deploys metric view definitions to a Databricks workspace using the API.
It reads YAML files and creates metric views in the specified catalog and schema.

Usage:
    python deploy_metric_views.py --catalog CATALOG --schema SCHEMA [--host HOST] [--token TOKEN]

Environment Variables:
    DATABRICKS_HOST: Databricks workspace URL
    DATABRICKS_TOKEN: Databricks access token
"""

import argparse
import os
import sys
from pathlib import Path
import yaml
import requests
import json


def load_metric_view(yaml_file: Path) -> dict:
    """Load metric view definition from YAML file."""
    with open(yaml_file, 'r') as f:
        return yaml.safe_load(f)


def create_metric_view_sql(view_name: str, view_def: dict, catalog: str, schema: str) -> str:
    """
    Generate SQL DDL for creating a metric view.
    
    Note: Metric views in Databricks are created using special syntax.
    This generates the YAML-based definition that can be submitted via API.
    """
    # The view definition itself is in YAML format
    # We need to submit it via the API
    return yaml.dump(view_def)


def deploy_metric_view(
    host: str,
    token: str,
    catalog: str,
    schema: str,
    view_name: str,
    view_definition: str
) -> bool:
    """
    Deploy a metric view using the Databricks API.
    
    Args:
        host: Databricks workspace URL
        token: Access token
        catalog: Target catalog name
        schema: Target schema name
        view_name: Name of the metric view
        view_definition: YAML definition of the metric view
    
    Returns:
        True if successful, False otherwise
    """
    # Endpoint for creating tables (metric views are a special type of table)
    url = f"{host}/api/2.1/unity-catalog/tables"
    
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "name": view_name,
        "catalog_name": catalog,
        "schema_name": schema,
        "table_type": "METRIC_VIEW",
        "view_definition": view_definition
    }
    
    try:
        response = requests.post(url, headers=headers, json=payload)
        
        if response.status_code in [200, 201]:
            print(f"✅ Successfully created: {catalog}.{schema}.{view_name}")
            return True
        elif response.status_code == 409:
            print(f"⚠️  Already exists: {catalog}.{schema}.{view_name}")
            # Try to update instead
            return update_metric_view(host, token, catalog, schema, view_name, view_definition)
        else:
            print(f"❌ Failed to create {view_name}: {response.status_code}")
            print(f"   Response: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Error deploying {view_name}: {str(e)}")
        return False


def update_metric_view(
    host: str,
    token: str,
    catalog: str,
    schema: str,
    view_name: str,
    view_definition: str
) -> bool:
    """Update an existing metric view."""
    url = f"{host}/api/2.1/unity-catalog/tables/{catalog}.{schema}.{view_name}"
    
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "view_definition": view_definition
    }
    
    try:
        response = requests.patch(url, headers=headers, json=payload)
        
        if response.status_code == 200:
            print(f"✅ Successfully updated: {catalog}.{schema}.{view_name}")
            return True
        else:
            print(f"❌ Failed to update {view_name}: {response.status_code}")
            print(f"   Response: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Error updating {view_name}: {str(e)}")
        return False


def main():
    parser = argparse.ArgumentParser(
        description="Deploy Databricks Semantic Layer metric views"
    )
    parser.add_argument(
        "--catalog",
        required=True,
        help="Target catalog name"
    )
    parser.add_argument(
        "--schema",
        required=True,
        help="Target schema name"
    )
    parser.add_argument(
        "--host",
        default=os.getenv("DATABRICKS_HOST"),
        help="Databricks workspace URL (or set DATABRICKS_HOST env var)"
    )
    parser.add_argument(
        "--token",
        default=os.getenv("DATABRICKS_TOKEN"),
        help="Databricks access token (or set DATABRICKS_TOKEN env var)"
    )
    parser.add_argument(
        "--views-dir",
        default="metric_views",
        help="Directory containing metric view YAML files"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print what would be deployed without actually deploying"
    )
    
    args = parser.parse_args()
    
    # Validate inputs
    if not args.host:
        print("Error: Databricks host not provided. Use --host or set DATABRICKS_HOST")
        sys.exit(1)
    
    if not args.token:
        print("Error: Databricks token not provided. Use --token or set DATABRICKS_TOKEN")
        sys.exit(1)
    
    # Ensure host has no trailing slash
    host = args.host.rstrip('/')
    
    # Find all YAML files
    views_dir = Path(args.views_dir)
    if not views_dir.exists():
        print(f"Error: Directory not found: {views_dir}")
        sys.exit(1)
    
    yaml_files = list(views_dir.glob("*.yaml"))
    if not yaml_files:
        print(f"Error: No YAML files found in {views_dir}")
        sys.exit(1)
    
    print(f"\n🚀 Deploying {len(yaml_files)} metric views to {args.catalog}.{args.schema}")
    print(f"   Workspace: {host}")
    print()
    
    # Deploy each view
    results = []
    for yaml_file in sorted(yaml_files):
        view_name = yaml_file.stem
        print(f"📊 Processing: {view_name}")
        
        try:
            # Load YAML definition
            with open(yaml_file, 'r') as f:
                view_definition = f.read()
            
            if args.dry_run:
                print(f"   [DRY RUN] Would create: {args.catalog}.{args.schema}.{view_name}")
                results.append(True)
            else:
                success = deploy_metric_view(
                    host,
                    args.token,
                    args.catalog,
                    args.schema,
                    view_name,
                    view_definition
                )
                results.append(success)
        
        except Exception as e:
            print(f"❌ Error processing {yaml_file}: {str(e)}")
            results.append(False)
        
        print()
    
    # Summary
    successful = sum(results)
    total = len(results)
    
    print("=" * 60)
    print(f"📈 Deployment Summary")
    print(f"   Total views: {total}")
    print(f"   Successful: {successful}")
    print(f"   Failed: {total - successful}")
    
    if successful == total:
        print("\n✅ All metric views deployed successfully!")
        sys.exit(0)
    else:
        print(f"\n⚠️  {total - successful} metric view(s) failed to deploy")
        sys.exit(1)


if __name__ == "__main__":
    main()
