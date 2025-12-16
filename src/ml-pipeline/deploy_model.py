#!/usr/bin/env python3
"""
Deploy a registered model to an Azure ML managed online endpoint.

This script creates or updates a managed online endpoint and deploys
the specified model version for real-time inference.
"""

import argparse
import sys
from pathlib import Path
from azure.ai.ml import MLClient
from azure.ai.ml.entities import (
    ManagedOnlineEndpoint,
    ManagedOnlineDeployment,
    Model,
    Environment,
    CodeConfiguration,
)
from azure.identity import DefaultAzureCredential


def parse_args():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Deploy model to Azure ML managed online endpoint"
    )
    parser.add_argument(
        "--subscription-id",
        required=True,
        help="Azure subscription ID",
    )
    parser.add_argument(
        "--resource-group",
        required=True,
        help="Azure resource group name",
    )
    parser.add_argument(
        "--workspace-name",
        required=True,
        help="Azure ML workspace name",
    )
    parser.add_argument(
        "--endpoint-name",
        required=True,
        help="Name of the managed online endpoint",
    )
    parser.add_argument(
        "--deployment-name",
        required=True,
        help="Name of the deployment",
    )
    parser.add_argument(
        "--model-name",
        required=True,
        help="Name of the registered model",
    )
    parser.add_argument(
        "--model-version",
        default=None,
        help="Version of the model (default: latest)",
    )
    parser.add_argument(
        "--instance-type",
        default="Standard_DS2_v2",
        help="Azure VM instance type (default: Standard_DS2_v2)",
    )
    parser.add_argument(
        "--instance-count",
        type=int,
        default=1,
        help="Number of instances (default: 1)",
    )
    return parser.parse_args()


def main():
    """Main entry point."""
    args = parse_args()
    
    print("=" * 60)
    print("Deploy Model to Managed Online Endpoint")
    print("=" * 60)
    print()
    
    # Connect to Azure ML workspace
    print(f"[deploy] Connecting to workspace '{args.workspace_name}' ...")
    try:
        ml_client = MLClient(
            credential=DefaultAzureCredential(),
            subscription_id=args.subscription_id,
            resource_group_name=args.resource_group,
            workspace_name=args.workspace_name,
        )
    except Exception as e:
        print(f"[ERROR] Failed to connect to workspace: {e}")
        sys.exit(1)
    
    # Get the model
    print(f"[deploy] Retrieving model '{args.model_name}' ...")
    try:
        if args.model_version:
            model = ml_client.models.get(name=args.model_name, version=args.model_version)
            print(f"[deploy] Using model version: {args.model_version}")
        else:
            model = ml_client.models.get(name=args.model_name, label="latest")
            print(f"[deploy] Using latest model version: {model.version}")
    except Exception as e:
        print(f"[ERROR] Failed to retrieve model: {e}")
        sys.exit(1)
    
    # Define paths
    script_dir = Path(__file__).parent
    repo_root = script_dir.parent.parent
    code_dir = repo_root / "src" / "deploy"
    env_file = code_dir / "env-infer.yml"
    
    if not env_file.exists():
        print(f"[ERROR] Environment file not found: {env_file}")
        sys.exit(1)
    
    print(f"[deploy] Using code directory: {code_dir}")
    print(f"[deploy] Using environment file: {env_file}")
    
    # Create or update endpoint
    print(f"[deploy] Creating or updating endpoint '{args.endpoint_name}' ...")
    try:
        endpoint = ManagedOnlineEndpoint(
            name=args.endpoint_name,
            description="House price prediction endpoint",
            auth_mode="key",
        )
        
        # Check if endpoint exists
        try:
            existing_endpoint = ml_client.online_endpoints.get(args.endpoint_name)
            print(f"[deploy] Endpoint '{args.endpoint_name}' already exists")
        except:
            print(f"[deploy] Creating new endpoint '{args.endpoint_name}' ...")
            ml_client.online_endpoints.begin_create_or_update(endpoint).result()
            print(f"[deploy] Endpoint created successfully")
    except Exception as e:
        print(f"[ERROR] Failed to create/update endpoint: {e}")
        sys.exit(1)
    
    # Create environment from YAML
    print(f"[deploy] Creating inference environment ...")
    try:
        environment = Environment(
            name="house-price-inference-env",
            description="Inference environment for house price prediction",
            conda_file=str(env_file),
            image="mcr.microsoft.com/azureml/openmpi4.1.0-ubuntu20.04:latest",
        )
    except Exception as e:
        print(f"[ERROR] Failed to create environment: {e}")
        sys.exit(1)
    
    # Create deployment
    print(f"[deploy] Creating or updating deployment '{args.deployment_name}' ...")
    try:
        deployment = ManagedOnlineDeployment(
            name=args.deployment_name,
            endpoint_name=args.endpoint_name,
            model=model,
            environment=environment,
            code_configuration=CodeConfiguration(
                code=str(code_dir),
                scoring_script="score.py",
            ),
            instance_type=args.instance_type,
            instance_count=args.instance_count,
        )
        
        ml_client.online_deployments.begin_create_or_update(deployment).result()
        print(f"[deploy] Deployment '{args.deployment_name}' created successfully")
    except Exception as e:
        print(f"[ERROR] Failed to create/update deployment: {e}")
        sys.exit(1)
    
    # Route 100% of traffic to this deployment
    print(f"[deploy] Routing 100% traffic to '{args.deployment_name}' ...")
    try:
        endpoint.traffic = {args.deployment_name: 100}
        ml_client.online_endpoints.begin_create_or_update(endpoint).result()
    except Exception as e:
        print(f"[ERROR] Failed to update traffic routing: {e}")
        sys.exit(1)
    
    # Get endpoint details
    try:
        endpoint = ml_client.online_endpoints.get(args.endpoint_name)
        scoring_uri = endpoint.scoring_uri
        
        # Get endpoint keys
        keys = ml_client.online_endpoints.get_keys(args.endpoint_name)
        primary_key = keys.primary_key
    except Exception as e:
        print(f"[ERROR] Failed to retrieve endpoint details: {e}")
        sys.exit(1)
    
    # Print success summary
    print()
    print("=" * 60)
    print("Deployment Successful")
    print("=" * 60)
    print(f"Endpoint Name:    {args.endpoint_name}")
    print(f"Deployment Name:  {args.deployment_name}")
    print(f"Model:            {args.model_name} (version {model.version})")
    print(f"Instance Type:    {args.instance_type}")
    print(f"Instance Count:   {args.instance_count}")
    print()
    print(f"Scoring URI:")
    print(f"  {scoring_uri}")
    print()
    print(f"Authorization Header:")
    print(f"  Authorization: Bearer {primary_key}")
    print()
    print("=" * 60)
    print()
    print("[deploy] You can now test the endpoint using Bruno or curl.")
    print("[deploy] Example curl command:")
    print()
    print(f'curl -X POST "{scoring_uri}" \\')
    print(f'  -H "Content-Type: application/json" \\')
    print(f'  -H "Authorization: Bearer {primary_key}" \\')
    print(f'  -d \'{{"data": [{{"sqft": 1800, "bedrooms": 3, "bathrooms": 2.0, "year_built": 1998, "neighborhood_code": "N3", "garage_spaces": 2, "condition_score": 7, "exterior_type": "siding"}}]}}\'')


if __name__ == "__main__":
    main()
