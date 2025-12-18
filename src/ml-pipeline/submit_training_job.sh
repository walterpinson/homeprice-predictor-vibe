#!/usr/bin/env bash
#
# Submit training job to Azure ML
#
# This script reads the infrastructure deployment outputs and invokes
# submit_training_job.py with the appropriate Azure configuration.
#
# Usage:
#   ./submit_training_job.sh [--experiment-name <name>] [--base-data-name <name>]
#
# Example:
#   ./submit_training_job.sh
#   ./submit_training_job.sh --experiment-name my-experiment

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
INFRA_DIR="$REPO_ROOT/src/infrastructure"
OUTPUTS_FILE="$INFRA_DIR/outputs.json"

echo "========================================="
echo "Submit Training Job to Azure ML"
echo "========================================="
echo ""

# Check if outputs.json exists
if [[ ! -f "$OUTPUTS_FILE" ]]; then
  echo "Error: Infrastructure outputs file not found: $OUTPUTS_FILE"
  echo ""
  echo "Please run the infrastructure deployment first:"
  echo "  cd src/infrastructure"
  echo "  ./deploy.sh --subscription-id <ID> --resource-group <RG> --location <LOC> --base-name <NAME>"
  exit 1
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
  echo "Error: jq is not installed."
  echo "Please install jq to parse JSON files."
  exit 1
fi

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
  echo "Error: python3 is not installed or not in PATH"
  exit 1
fi

# Extract configuration from outputs.json
echo "[job] Reading infrastructure configuration..."
SUBSCRIPTION_ID=$(jq -r '.subscriptionId' "$OUTPUTS_FILE")
RESOURCE_GROUP=$(jq -r '.resourceGroup' "$OUTPUTS_FILE")
WORKSPACE_NAME=$(jq -r '.workspaceName' "$OUTPUTS_FILE")

if [[ -z "$SUBSCRIPTION_ID" || "$SUBSCRIPTION_ID" == "null" ]]; then
  echo "Error: Could not read subscriptionId from $OUTPUTS_FILE"
  exit 1
fi

if [[ -z "$RESOURCE_GROUP" || "$RESOURCE_GROUP" == "null" ]]; then
  echo "Error: Could not read resourceGroup from $OUTPUTS_FILE"
  exit 1
fi

if [[ -z "$WORKSPACE_NAME" || "$WORKSPACE_NAME" == "null" ]]; then
  echo "Error: Could not read workspaceName from $OUTPUTS_FILE"
  exit 1
fi

# Compute cluster name from outputs.json
COMPUTE_CLUSTER=$(jq -r '.computeCluster' "$OUTPUTS_FILE")

if [[ -z "$COMPUTE_CLUSTER" || "$COMPUTE_CLUSTER" == "null" ]]; then
  echo "Error: Could not read computeCluster from $OUTPUTS_FILE"
  exit 1
fi

echo "[job] Configuration:"
echo "  Subscription ID:  $SUBSCRIPTION_ID"
echo "  Resource Group:   $RESOURCE_GROUP"
echo "  Workspace Name:   $WORKSPACE_NAME"
echo "  Compute Cluster:  $COMPUTE_CLUSTER"
echo ""

# Invoke the Python script
cd "$SCRIPT_DIR"
python3 submit_training_job.py \
  --subscription-id "$SUBSCRIPTION_ID" \
  --resource-group "$RESOURCE_GROUP" \
  --workspace-name "$WORKSPACE_NAME" \
  --compute-cluster "$COMPUTE_CLUSTER" \
  "$@"
