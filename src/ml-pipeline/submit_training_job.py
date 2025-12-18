#!/usr/bin/env python3
"""
Submit a training job to Azure ML.

This script creates and submits a command job to Azure ML that runs the
training script (train.py) on registered MLTable data assets.
"""

import argparse
import sys
from pathlib import Path
from azure.ai.ml import MLClient, command, Input
from azure.ai.ml.entities import Environment
from azure.identity import DefaultAzureCredential
from azure.ai.ml.constants import AssetTypes


def parse_args():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Submit training job to Azure ML"
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
        "--compute-cluster",
        required=True,
        help="Name of the AmlCompute cluster",
    )
    parser.add_argument(
        "--base-data-name",
        default="house-prices",
        help="Base name for data assets (default: house-prices)",
    )
    parser.add_argument(
        "--experiment-name",
        default="house-price-training",
        help="Experiment name (default: house-price-training)",
    )
    parser.add_argument(
        "--environment-file",
        default="../deploy/env-train.yml",
        help="Path to environment YAML file (default: ../deploy/env-train.yml)",
    )
    return parser.parse_args()


def main():
    """Main entry point."""
    args = parse_args()
    
    print("=" * 60)
    print("Submit Training Job to Azure ML")
    print("=" * 60)
    print()
    
    # Connect to Azure ML workspace
    print(f"[job] Connecting to workspace '{args.workspace_name}' ...")
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
    
    # Resolve environment file path
    script_dir = Path(__file__).parent
    env_file = script_dir / args.environment_file
    if not env_file.exists():
        print(f"[ERROR] Environment file not found: {env_file}")
        sys.exit(1)
    
    print(f"[job] Using environment from: {env_file}")
    
    # Create environment from YAML
    try:
        environment = Environment(
            name="house-price-training-env",
            description="Training environment for house price prediction",
            conda_file=str(env_file),
            image="mcr.microsoft.com/azureml/openmpi4.1.0-ubuntu20.04:latest",
        )
    except Exception as e:
        print(f"[ERROR] Failed to create environment: {e}")
        sys.exit(1)
    
    # Define data asset references (using version 2)
    train_data_name = f"{args.base_data_name}-train"
    val_data_name = f"{args.base_data_name}-val"
    data_version = "2"
    
    print(f"[job] Referencing data assets (version {data_version}):")
    print(f"  Training:   {train_data_name}")
    print(f"  Validation: {val_data_name}")
    
    # Create the command job
    print(f"[job] Creating command job ...")
    try:
        job = command(
            code=str(script_dir),
            command="python train.py --train-data ${{inputs.train_data}} --val-data ${{inputs.val_data}} --target-column price",
            inputs={
                "train_data": Input(
                    type=AssetTypes.MLTABLE,
                    path=f"azureml:{train_data_name}:{data_version}",
                ),
                "val_data": Input(
                    type=AssetTypes.MLTABLE,
                    path=f"azureml:{val_data_name}:{data_version}",
                ),
            },
            environment=environment,
            compute=args.compute_cluster,
            experiment_name=args.experiment_name,
            display_name="House Price Model Training",
            description="Train a scikit-learn regression model for house price prediction",
        )
    except Exception as e:
        print(f"[ERROR] Failed to create job: {e}")
        sys.exit(1)
    
    # Submit the job
    print(f"[job] Submitting training job to Azure ML ...")
    try:
        submitted_job = ml_client.jobs.create_or_update(job)
    except Exception as e:
        print(f"[ERROR] Failed to submit job: {e}")
        sys.exit(1)
    
    # Print job details
    print()
    print("=" * 60)
    print("Job Submitted Successfully")
    print("=" * 60)
    print(f"Job Name:    {submitted_job.name}")
    print(f"Job ID:      {submitted_job.id}")
    print(f"Status:      {submitted_job.status}")
    print(f"Experiment:  {args.experiment_name}")
    print()
    print(f"View in Azure ML Studio:")
    print(f"  {submitted_job.studio_url}")
    print("=" * 60)
    print()
    print(f"[job] Job Name: {submitted_job.name}")
    print(f"[job] Use this job name for model registration after completion.")


if __name__ == "__main__":
    main()
