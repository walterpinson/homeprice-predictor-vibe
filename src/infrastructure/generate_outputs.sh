#!/usr/bin/env bash
#
# Generate outputs.json from existing Azure ML workspace
#
# Usage:
#   ./generate_outputs.sh \
#     --subscription-id <SUBSCRIPTION_ID> \
#     --resource-group <RESOURCE_GROUP>

set -euo pipefail

# Parse arguments
SUBSCRIPTION_ID=""
RESOURCE_GROUP=""

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
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$SUBSCRIPTION_ID" || -z "$RESOURCE_GROUP" ]]; then
  echo "Error: Missing required arguments"
  echo ""
  echo "Usage:"
  echo "  ./generate_outputs.sh \\"
  echo "    --subscription-id <SUBSCRIPTION_ID> \\"
  echo "    --resource-group <RESOURCE_GROUP>"
  exit 1
fi

echo "[generate] Setting subscription..."
az account set --subscription "$SUBSCRIPTION_ID"

echo "[generate] Fetching resource group details..."
LOCATION=$(az group show --name "$RESOURCE_GROUP" --query location -o tsv)

echo "[generate] Discovering Azure ML workspace..."
WORKSPACE_NAME=$(az ml workspace list \
  --resource-group "$RESOURCE_GROUP" \
  --query "[0].name" -o tsv)

if [[ -z "$WORKSPACE_NAME" || "$WORKSPACE_NAME" == "null" ]]; then
  echo "Error: No Azure ML workspace found in resource group $RESOURCE_GROUP"
  exit 1
fi

echo "[generate] Found workspace: $WORKSPACE_NAME"

echo "[generate] Fetching associated resources..."

# Get workspace details to find associated resources
WORKSPACE_DETAILS=$(az ml workspace show \
  --name "$WORKSPACE_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query "{storage:storage_account,keyvault:key_vault,acr:container_registry,appinsights:application_insights}" \
  -o json)

# Extract resource names from full resource IDs
STORAGE_NAME=$(echo "$WORKSPACE_DETAILS" | jq -r '.storage' | awk -F'/' '{print $NF}')
KEYVAULT_NAME=$(echo "$WORKSPACE_DETAILS" | jq -r '.keyvault' | awk -F'/' '{print $NF}')
ACR_NAME=$(echo "$WORKSPACE_DETAILS" | jq -r '.acr' | awk -F'/' '{print $NF}')
APPINSIGHTS_NAME=$(echo "$WORKSPACE_DETAILS" | jq -r '.appinsights' | awk -F'/' '{print $NF}')

echo "[generate] Creating outputs.json..."
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
echo "outputs.json Generated"
echo "========================================="
echo "Subscription ID:     $SUBSCRIPTION_ID"
echo "Resource Group:      $RESOURCE_GROUP"
echo "Location:            $LOCATION"
echo "Workspace:           $WORKSPACE_NAME"
echo "Storage Account:     $STORAGE_NAME"
echo "Key Vault:           $KEYVAULT_NAME"
echo "Container Registry:  $ACR_NAME"
echo "App Insights:        $APPINSIGHTS_NAME"
echo "========================================="
echo ""
echo "File saved to: $(dirname "$0")/outputs.json"
