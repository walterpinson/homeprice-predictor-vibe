#!/usr/bin/env python3
"""
Register a trained model from an Azure ML job into the model registry.

This script retrieves the trained model artifact from a completed Azure ML job
and registers it in the workspace model registry for deployment.
"""

import argparse
import sys
from azure.ai.ml import MLClient
from azure.ai.ml.entities import Model
from azure.identity import DefaultAzureCredential
from azure.ai.ml.constants import AssetTypes


def parse_args():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Register trained model from Azure ML job"
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
        "--job-name",
        required=True,
        help="Name or ID of the completed training job",
    )
    parser.add_argument(
        "--model-name",
        default="house-price-regressor",
        help="Name for the registered model (default: house-price-regressor)",
    )
    parser.add_argument(
        "--model-version-tag",
        default=None,
        help="Optional tag for model version metadata",
    )
    return parser.parse_args()


def main():
    """Main entry point."""
    args = parse_args()
    
    print("=" * 60)
    print("Register Model from Training Job")
    print("=" * 60)
    print()
    
    # Connect to Azure ML workspace
    print(f"[model] Connecting to workspace '{args.workspace_name}' ...")
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
    
    # Retrieve the job details
    print(f"[model] Retrieving job details for '{args.job_name}' ...")
    try:
        job = ml_client.jobs.get(args.job_name)
    except Exception as e:
        print(f"[ERROR] Failed to retrieve job: {e}")
        print(f"[ERROR] Make sure the job name '{args.job_name}' is correct.")
        sys.exit(1)
    
    # Check job status
    print(f"[model] Job status: {job.status}")
    if job.status != "Completed":
        print(f"[WARNING] Job is not in 'Completed' status.")
        print(f"[WARNING] Model registration may fail if outputs are not available.")
    
    # Construct the path to the model artifact
    # Azure ML jobs save outputs to azureml://jobs/<job-name>/outputs/
    model_path = f"azureml://jobs/{args.job_name}/outputs/artifacts/paths/outputs/model.pkl"
    
    print(f"[model] Model artifact path: {model_path}")
    
    # Prepare model tags
    tags = {
        "framework": "scikit-learn",
        "task": "regression",
        "scenario": "house-price-prediction",
        "training_job": args.job_name,
    }
    
    if args.model_version_tag:
        tags["version_tag"] = args.model_version_tag
    
    # Create the Model object
    print(f"[model] Registering model '{args.model_name}' ...")
    try:
        model = Model(
            name=args.model_name,
            path=model_path,
            type=AssetTypes.CUSTOM_MODEL,
            description="House price prediction regression model trained with scikit-learn",
            tags=tags,
        )
        
        registered_model = ml_client.models.create_or_update(model)
    except Exception as e:
        print(f"[ERROR] Failed to register model: {e}")
        print(f"[ERROR] Verify that the job completed successfully and produced outputs.")
        sys.exit(1)
    
    # Print success message
    print()
    print("=" * 60)
    print("Model Registered Successfully")
    print("=" * 60)
    print(f"Model Name:    {registered_model.name}")
    print(f"Model Version: {registered_model.version}")
    print(f"Model ID:      {registered_model.id}")
    print()
    print("Tags:")
    for key, value in registered_model.tags.items():
        print(f"  {key}: {value}")
    print("=" * 60)
    print()
    print(f"[model] Model '{registered_model.name}' version {registered_model.version} is now available for deployment.")


if __name__ == "__main__":
    main()
