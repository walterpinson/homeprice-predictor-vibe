#!/usr/bin/env bash
#
# Deploy model to Azure ML managed online endpoint
#
# This script reads the infrastructure deployment outputs and invokes
# deploy_model_endpoint.py with the appropriate Azure configuration.
#
# Usage:
#   ./deploy_model_endpoint.sh \
#     --model-name <name> \
#     --model-version <version> \
#     --endpoint-name <endpoint> \
#     [--deployment-name <deployment>] \
#     [--instance-type <type>] \
#     [--instance-count <count>]
#
# Example:
#   ./deploy_model_endpoint.sh \
#     --model-name house-pricing-01 \
#     --model-version 1 \
#     --endpoint-name house-price-ep

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
INFRA_DIR="$REPO_ROOT/src/infrastructure"
OUTPUTS_FILE="$INFRA_DIR/outputs.json"

echo "========================================="
echo "Deploy Model to Managed Online Endpoint"
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
MODEL_NAME=""
MODEL_VERSION=""
ENDPOINT_NAME=""
DEPLOYMENT_NAME="blue"
EXTRA_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    --model-name)
      MODEL_NAME="$2"
      shift 2
      ;;
    --model-version)
      MODEL_VERSION="$2"
      shift 2
      ;;
    --endpoint-name)
      ENDPOINT_NAME="$2"
      shift 2
      ;;
    --deployment-name)
      DEPLOYMENT_NAME="$2"
      shift 2
      ;;
    --instance-type|--instance-count)
      EXTRA_ARGS+=("$1" "$2")
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo ""
      echo "Usage: $0 --model-name <name> --model-version <version> --endpoint-name <endpoint> [options]"
      exit 1
      ;;
  esac
done

# Validate required arguments
if [[ -z "$MODEL_NAME" ]]; then
  echo "Error: --model-name is required"
  echo ""
  echo "Usage: $0 --model-name <name> --model-version <version> --endpoint-name <endpoint> [options]"
  exit 1
fi

if [[ -z "$MODEL_VERSION" ]]; then
  echo "Error: --model-version is required"
  echo ""
  echo "Usage: $0 --model-name <name> --model-version <version> --endpoint-name <endpoint> [options]"
  exit 1
fi

if [[ -z "$ENDPOINT_NAME" ]]; then
  echo "Error: --endpoint-name is required"
  echo ""
  echo "Usage: $0 --model-name <name> --model-version <version> --endpoint-name <endpoint> [options]"
  exit 1
fi

# Extract configuration from outputs.json
echo "[deploy] Reading infrastructure configuration..."
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

echo "[deploy] Configuration:"
echo "  Subscription ID:  $SUBSCRIPTION_ID"
echo "  Resource Group:   $RESOURCE_GROUP"
echo "  Workspace Name:   $WORKSPACE_NAME"
echo "  Model Name:       $MODEL_NAME"
echo "  Model Version:    $MODEL_VERSION"
echo "  Endpoint Name:    $ENDPOINT_NAME"
echo "  Deployment Name:  $DEPLOYMENT_NAME"
echo ""

# Invoke the Python script
cd "$SCRIPT_DIR"
python3 deploy_model_endpoint.py \
  --subscription-id "$SUBSCRIPTION_ID" \
  --resource-group "$RESOURCE_GROUP" \
  --workspace-name "$WORKSPACE_NAME" \
  --model-name "$MODEL_NAME" \
  --model-version "$MODEL_VERSION" \
  --endpoint-name "$ENDPOINT_NAME" \
  --deployment-name "$DEPLOYMENT_NAME" \
  "${EXTRA_ARGS[@]}"
