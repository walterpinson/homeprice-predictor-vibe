#!/usr/bin/env python3
"""
Register MLTable data assets in Azure ML workspace.

This script registers train/val/test MLTable definitions as named data assets
in the Azure ML workspace, making them available for training jobs.
"""

import argparse
import sys
from pathlib import Path
from azure.ai.ml import MLClient
from azure.ai.ml.entities import Data
from azure.ai.ml.constants import AssetTypes
from azure.identity import DefaultAzureCredential


def parse_args():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Register MLTable data assets in Azure ML workspace"
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
        "--datastore-name",
        default=None,
        help="Datastore name (optional, uses workspace default if omitted)",
    )
    parser.add_argument(
        "--base-data-name",
        default="house-prices",
        help="Base name for data assets (default: house-prices)",
    )
    return parser.parse_args()


def register_mltable(
    ml_client: MLClient,
    split: str,
    base_name: str,
    mltable_path: Path,
) -> Data:
    """
    Register a single MLTable data asset.

    Args:
        ml_client: Azure ML client
        split: Data split name (train, val, or test)
        base_name: Base name for the data asset
        mltable_path: Path to the MLTable directory (must contain both MLTable file and CSV)

    Returns:
        Registered Data asset
    """
    asset_name = f"{base_name}-{split}"
    
    print(f"[data] Registering {split} data asset (uploading MLTable + CSV to cloud) ...")
    
    # MLTable folder must be self-contained (CSV in same directory as MLTable file)
    # Azure ML uploads only the specified folder, not parent directories
    data_asset = Data(
        name=asset_name,
        path=str(mltable_path),
        type=AssetTypes.MLTABLE,
        description=f"House price prediction {split} dataset (MLTable format)",
    )
    
    registered_asset = ml_client.data.create_or_update(data_asset)
    
    return registered_asset


def main():
    """Main entry point."""
    args = parse_args()
    
    # Get the repository root (assuming script is in src/ml-pipeline/)
    script_dir = Path(__file__).parent
    repo_root = script_dir.parent.parent
    mltable_base = repo_root / "src" / "data" / "mltable"
    
    # Verify MLTable directories exist
    splits = ["train", "val", "test"]
    for split in splits:
        mltable_dir = mltable_base / split
        if not mltable_dir.exists():
            print(f"[ERROR] MLTable directory not found: {mltable_dir}")
            sys.exit(1)
        mltable_file = mltable_dir / "MLTable"
        if not mltable_file.exists():
            print(f"[ERROR] MLTable file not found: {mltable_file}")
            sys.exit(1)
    
    # Connect to Azure ML workspace
    print(f"[data] Connecting to workspace '{args.workspace_name}' ...")
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
    
    # Register each MLTable data asset
    registered_assets = {}
    for split in splits:
        mltable_path = mltable_base / split
        try:
            asset = register_mltable(
                ml_client=ml_client,
                split=split,
                base_name=args.base_data_name,
                mltable_path=mltable_path,
            )
            registered_assets[split] = asset
            print(f"[data] ✓ Registered: {asset.name} (version {asset.version})")
        except Exception as e:
            print(f"[ERROR] Failed to register {split} data asset: {e}")
            sys.exit(1)
    
    # Print summary
    print()
    print("=" * 60)
    print("Data Asset Registration Summary")
    print("=" * 60)
    for split in splits:
        asset = registered_assets[split]
        print(f"  {split.upper():5s} → {asset.name:25s} v{asset.version}")
    print("=" * 60)
    print()
    print("[data] All data assets registered successfully!")


if __name__ == "__main__":
    main()
