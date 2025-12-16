#!/usr/bin/env bash
#
# Register model from completed Azure ML training job
#
# This script reads the infrastructure deployment outputs and invokes
# register_model.py with the appropriate Azure configuration.
#
# Usage:
#   ./register_model.sh --job-name <job-name> [--model-name <name>]
#
# Example:
#   ./register_model.sh --job-name calm_garlic_kgs6n4bmkh
#   ./register_model.sh --job-name calm_garlic_kgs6n4bmkh --model-name my-model

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
INFRA_DIR="$REPO_ROOT/src/infrastructure"
OUTPUTS_FILE="$INFRA_DIR/outputs.json"

echo "========================================="
echo "Register Model from Training Job"
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

# Parse arguments
JOB_NAME=""
MODEL_NAME="house-price-regressor"

while [[ $# -gt 0 ]]; do
  case $1 in
    --job-name)
      JOB_NAME="$2"
      shift 2
      ;;
    --model-name)
      MODEL_NAME="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo ""
      echo "Usage: $0 --job-name <job-name> [--model-name <name>]"
      exit 1
      ;;
  esac
done

# Validate required arguments
if [[ -z "$JOB_NAME" ]]; then
  echo "Error: --job-name is required"
  echo ""
  echo "Usage: $0 --job-name <job-name> [--model-name <name>]"
  exit 1
fi

# Extract configuration from outputs.json
echo "[model] Reading infrastructure configuration..."
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

echo "[model] Configuration:"
echo "  Subscription ID:  $SUBSCRIPTION_ID"
echo "  Resource Group:   $RESOURCE_GROUP"
echo "  Workspace Name:   $WORKSPACE_NAME"
echo "  Job Name:         $JOB_NAME"
echo "  Model Name:       $MODEL_NAME"
echo ""

# Invoke the Python script
cd "$SCRIPT_DIR"
python3 register_model.py \
  --subscription-id "$SUBSCRIPTION_ID" \
  --resource-group "$RESOURCE_GROUP" \
  --workspace-name "$WORKSPACE_NAME" \
  --job-name "$JOB_NAME" \
  --model-name "$MODEL_NAME"
