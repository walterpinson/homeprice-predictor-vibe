#!/usr/bin/env bash
#
# Deploy Azure ML infrastructure using Bicep template
#
# Usage:
#   ./deploy.sh \
#     --subscription-id <SUBSCRIPTION_ID> \
#     --resource-group <RESOURCE_GROUP> \
#     --location <LOCATION> \
#     --base-name <BASE_NAME>
#
# Example:
#   ./deploy.sh \
#     --subscription-id "12345678-1234-1234-1234-123456789abc" \
#     --resource-group "rg-ml-demo" \
#     --location "eastus" \
#     --base-name "mldemo"

set -euo pipefail

# =============================================================================
# PREREQUISITES CHECK
# =============================================================================

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
  echo "Error: Azure CLI (az) is not installed."
  echo "Please install it from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
  exit 1
fi

# Check if user is logged in
if ! az account show &> /dev/null; then
  echo "Error: Not logged in to Azure CLI."
  echo "Please run 'az login' first."
  exit 1
fi

# =============================================================================
# ARGUMENT PARSING
# =============================================================================

SUBSCRIPTION_ID=""
RESOURCE_GROUP=""
LOCATION=""
BASE_NAME=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --subscription-id)
      SUBSCRIPTION_ID="$2"
      shift 2
      ;;
    --resource-group)
      RESOURCE_GROUP="$2"
      shift 2
      ;;
    --location)
      LOCATION="$2"
      shift 2
      ;;
    --base-name)
      BASE_NAME="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Validate required arguments
if [[ -z "$SUBSCRIPTION_ID" || -z "$RESOURCE_GROUP" || -z "$LOCATION" || -z "$BASE_NAME" ]]; then
  echo "Error: Missing required arguments"
  echo ""
  echo "Usage:"
  echo "  ./deploy.sh \\"
  echo "    --subscription-id <SUBSCRIPTION_ID> \\"
  echo "    --resource-group <RESOURCE_GROUP> \\"
  echo "    --location <LOCATION> \\"
  echo "    --base-name <BASE_NAME>"
  echo ""
  echo "Example:"
  echo "  ./deploy.sh \\"
  echo "    --subscription-id \"12345678-1234-1234-1234-123456789abc\" \\"
  echo "    --resource-group \"rg-ml-demo\" \\"
  echo "    --location \"eastus\" \\"
  echo "    --base-name \"mldemo\""
  exit 1
fi

# =============================================================================
# DEPLOYMENT
# =============================================================================

echo "[deploy] Setting Azure subscription..."
az account set --subscription "$SUBSCRIPTION_ID"

echo "[deploy] Creating resource group '$RESOURCE_GROUP' in '$LOCATION'..."
if ! az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output none; then
  echo "Error: Failed to create resource group"
  exit 1
fi

echo "[deploy] Running Bicep deployment..."
DEPLOYMENT_NAME="ml-infra-$(date +%Y%m%d-%H%M%S)"
if ! az deployment group create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$DEPLOYMENT_NAME" \
  --template-file "$(dirname "$0")/main.bicep" \
  --parameters location="$LOCATION" baseName="$BASE_NAME" \
  --output none; then
  echo "Error: Deployment failed"
  exit 1
fi

# =============================================================================
# DEPLOYMENT OUTPUTS
# =============================================================================

echo "[deploy] Retrieving deployment outputs..."
OUTPUTS=$(az deployment group show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$DEPLOYMENT_NAME" \
  --query properties.outputs \
  --output json)

WORKSPACE_NAME=$(echo "$OUTPUTS" | jq -r '.workspaceName.value')
STORAGE_NAME=$(echo "$OUTPUTS" | jq -r '.storageAccountName.value')
KEYVAULT_NAME=$(echo "$OUTPUTS" | jq -r '.keyVaultName.value')
ACR_NAME=$(echo "$OUTPUTS" | jq -r '.containerRegistryName.value')
APPINSIGHTS_NAME=$(echo "$OUTPUTS" | jq -r '.appInsightsName.value')

echo "[deploy] Saving deployment outputs to outputs.json..."
cat > "$(dirname "$0")/outputs.json" <<EOF
{
  "subscriptionId": "$SUBSCRIPTION_ID",
  "resourceGroup": "$RESOURCE_GROUP",
  "location": "$LOCATION",
  "workspaceName": "$WORKSPACE_NAME",
  "storageAccountName": "$STORAGE_NAME",
  "keyVaultName": "$KEYVAULT_NAME",
  "containerRegistryName": "$ACR_NAME",
  "appInsightsName": "$APPINSIGHTS_NAME"
}
EOF

echo ""
echo "========================================="
echo "Deployment Summary"
echo "========================================="
echo "Workspace:          $WORKSPACE_NAME"
echo "Storage Account:    $STORAGE_NAME"
echo "Key Vault:          $KEYVAULT_NAME"
echo "Container Registry: $ACR_NAME"
echo "App Insights:       $APPINSIGHTS_NAME"
echo "========================================="
echo ""
echo "[deploy] Deployment complete!"
echo "[deploy] Configuration saved to outputs.json"
