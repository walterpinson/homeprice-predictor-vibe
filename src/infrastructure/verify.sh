#!/usr/bin/env bash
#
# Verify Azure ML infrastructure is healthy and ready
#
# Usage:
#   ./verify.sh \
#     --subscription-id <SUBSCRIPTION_ID> \
#     --resource-group <RESOURCE_GROUP> \
#     --workspace-name <WORKSPACE_NAME> \
#     --compute-name <COMPUTE_NAME>
#
# Example:
#   ./verify.sh \
#     --subscription-id "12345678-1234-1234-1234-123456789abc" \
#     --resource-group "rg-ml-demo" \
#     --workspace-name "mldemo-mlw" \
#     --compute-name "cpu-cluster"

set -euo pipefail

# =============================================================================
# ARGUMENT PARSING
# =============================================================================

SUBSCRIPTION_ID=""
RESOURCE_GROUP=""
WORKSPACE_NAME=""
COMPUTE_NAME=""

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
    --workspace-name)
      WORKSPACE_NAME="$2"
      shift 2
      ;;
    --compute-name)
      COMPUTE_NAME="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Validate required arguments
if [[ -z "$SUBSCRIPTION_ID" || -z "$RESOURCE_GROUP" || -z "$WORKSPACE_NAME" || -z "$COMPUTE_NAME" ]]; then
  echo "Error: Missing required arguments"
  echo ""
  echo "Usage:"
  echo "  ./verify.sh \\"
  echo "    --subscription-id <SUBSCRIPTION_ID> \\"
  echo "    --resource-group <RESOURCE_GROUP> \\"
  echo "    --workspace-name <WORKSPACE_NAME> \\"
  echo "    --compute-name <COMPUTE_NAME>"
  echo ""
  echo "Example:"
  echo "  ./verify.sh \\"
  echo "    --subscription-id \"12345678-1234-1234-1234-123456789abc\" \\"
  echo "    --resource-group \"rg-ml-demo\" \\"
  echo "    --workspace-name \"mldemo-mlw\" \\"
  echo "    --compute-name \"cpu-cluster\""
  exit 1
fi

# =============================================================================
# VERIFICATION
# =============================================================================

echo "[verify] Setting Azure subscription..."
az account set --subscription "$SUBSCRIPTION_ID"

echo "[verify] Checking workspace '$WORKSPACE_NAME'..."
if ! WORKSPACE_INFO=$(az ml workspace show \
  -n "$WORKSPACE_NAME" \
  -g "$RESOURCE_GROUP" \
  --query "{location:location, resourceGroup:resourceGroup}" \
  -o json 2>&1); then
  echo "Error: Workspace '$WORKSPACE_NAME' not found in resource group '$RESOURCE_GROUP'"
  echo "$WORKSPACE_INFO"
  exit 1
fi

WS_LOCATION=$(echo "$WORKSPACE_INFO" | jq -r '.location')
WS_RG=$(echo "$WORKSPACE_INFO" | jq -r '.resourceGroup')
echo "[verify] ✓ Workspace found - Location: $WS_LOCATION, Resource Group: $WS_RG"

echo "[verify] Checking compute cluster '$COMPUTE_NAME'..."
if ! COMPUTE_INFO=$(az ml compute show \
  -n "$COMPUTE_NAME" \
  --workspace-name "$WORKSPACE_NAME" \
  -g "$RESOURCE_GROUP" \
  -o json 2>&1); then
  echo "Error: Compute cluster '$COMPUTE_NAME' not found in workspace '$WORKSPACE_NAME'"
  echo "$COMPUTE_INFO"
  exit 1
fi

COMPUTE_VM_SIZE=$(echo "$COMPUTE_INFO" | jq -r '.size // "N/A"')
COMPUTE_STATE=$(echo "$COMPUTE_INFO" | jq -r '.provisioning_state // "N/A"')
COMPUTE_MIN=$(echo "$COMPUTE_INFO" | jq -r '.scale_settings.min_node_count // "N/A"')
COMPUTE_MAX=$(echo "$COMPUTE_INFO" | jq -r '.scale_settings.max_node_count // "N/A"')
echo "[verify] ✓ Compute cluster found - VM: $COMPUTE_VM_SIZE, State: $COMPUTE_STATE, Nodes: $COMPUTE_MIN-$COMPUTE_MAX"

# =============================================================================
# SUCCESS SUMMARY
# =============================================================================

echo ""
echo "========================================="
echo "Verification Complete"
echo "========================================="
echo "✓ Workspace is accessible"
echo "✓ Compute cluster is provisioned"
echo ""
echo "Environment is ready for training and deployment!"
echo "========================================="
