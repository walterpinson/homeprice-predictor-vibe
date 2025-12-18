#!/usr/bin/env bash
#
# reset-demo.sh
# Reset repository from "demo-ready" to "demo-start" state
#
# This script removes generated artifacts while preserving infrastructure,
# prompts, stable scaffolding, and documentation.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--dry-run]"
      exit 1
      ;;
  esac
done

if [[ "$DRY_RUN" == "true" ]]; then
  echo "========================================="
  echo "DRY RUN MODE (no files will be deleted)"
  echo "========================================="
  echo ""
fi

echo "========================================="
echo "Resetting Demo to Start State"
echo "========================================="
echo ""

REMOVED_COUNT=0

# Helper function to remove file or directory
remove_item() {
  local item="$1"
  
  if [[ ! -e "$item" ]]; then
    return
  fi
  
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[dry-run] Would remove: $item"
  else
    echo "[reset] Removing: $item"
    rm -rf "$item" || {
      echo "[reset] Warning: Failed to remove $item"
      return
    }
  fi
  
  REMOVED_COUNT=$((REMOVED_COUNT + 1))
}

# Remove ML pipeline scripts
echo "[reset] Cleaning ML pipeline scripts..."
remove_item "src/ml-pipeline/register_data.py"
remove_item "src/ml-pipeline/register_data.sh"
remove_item "src/ml-pipeline/train.py"
remove_item "src/ml-pipeline/submit_training_job.py"
remove_item "src/ml-pipeline/submit_training_job.sh"
remove_item "src/ml-pipeline/register_model.py"
remove_item "src/ml-pipeline/register_model.sh"
remove_item "src/ml-pipeline/deploy_model_endpoint.py"
remove_item "src/ml-pipeline/deploy_model_endpoint.sh"
echo ""

# Remove data artifacts
echo "[reset] Cleaning data artifacts..."
remove_item "src/data/README.md"
remove_item "src/data/prepare_mltables.sh"
remove_item "src/data/generate_synthetic_data.py"
remove_item "src/data/generate_data.sh"

# Remove raw CSV files
if [[ -d "src/data/raw" ]]; then
  for csv in src/data/raw/*.csv; do
    if [[ -f "$csv" ]]; then
      remove_item "$csv"
    fi
  done
fi

# Remove MLTable directories
remove_item "src/data/mltable/train"
remove_item "src/data/mltable/val"
remove_item "src/data/mltable/test"
echo ""

# Remove infrastructure outputs
echo "[reset] Cleaning infrastructure outputs..."
remove_item "src/infrastructure/outputs.json"
remove_item "src/infrastructure/generate_outputs.sh"
echo ""

# Remove deployment artifacts
echo "[reset] Cleaning deployment artifacts..."
remove_item "src/deploy/score.py"
remove_item "src/deploy/env-infer.yml"
echo ""

# Remove Bruno secrets
echo "[reset] Cleaning Bruno secrets..."
remove_item "bruno/house-price-api/environments/demo.bru"
echo ""

# Remove Python cache files
echo "[reset] Cleaning Python cache files..."
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -type f -name "*.pyc" -delete 2>/dev/null || true
echo ""

# Summary
echo "========================================="
echo "Reset Complete"
echo "========================================="
echo ""

if [[ "$DRY_RUN" == "true" ]]; then
  echo "DRY RUN: $REMOVED_COUNT items would be removed"
else
  echo "Removed $REMOVED_COUNT items"
fi

echo ""
echo "Repository is now in 'demo-start' state."
echo ""
echo "To rebuild for the demo, follow the steps in:"
echo "  presentation/DEMO-SCRIPTS.md"
echo ""
echo "Preserved items:"
echo "  ✓ Infrastructure code (src/infrastructure/)"
echo "  ✓ Training environment (src/deploy/env-train.yml)"
echo "  ✓ Bruno collection structure (bruno/)"
echo "  ✓ All prompts and documentation (.github/, presentation/)"
echo ""
