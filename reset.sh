#!/usr/bin/env bash
#
# reset.sh
# Complete reset - removes ALL generated artifacts under src/
#
# This is more aggressive than reset-demo.sh. It removes everything
# that can be regenerated using the Copilot prompts, including
# infrastructure scripts, training environments, and all artifacts.
#
# Use this when:
# - Setting up a clean repository for new users
# - Starting completely from scratch
# - Creating a pristine demo-segment-1 branch
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              COMPLETE REPOSITORY RESET                         ║"
echo "║         (Removes ALL generated src/ artifacts)                 ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "[reset] ⚠️  WARNING: This will remove ALL generated files under src/"
echo "[reset] This includes:"
echo "[reset]   - Infrastructure scripts (main.bicep, deploy.sh, verify.sh)"
echo "[reset]   - All environment files (env-train.yml, env-infer.yml)"
echo "[reset]   - All ML pipeline scripts"
echo "[reset]   - All data artifacts"
echo "[reset]   - All deployment scripts"
echo "[reset]   - Entire Bruno collection (bruno/house-price-api/)"
echo ""
echo "[reset] Only .github/, presentation/, and documentation will be preserved."
echo "[reset] You'll regenerate everything using Copilot prompts."
echo ""
read -p "Are you sure? (type 'yes' to confirm) " -r
echo ""

if [[ "$REPLY" != "yes" ]]; then
    echo "[reset] Aborted."
    exit 0
fi

echo ""
echo "[reset] Removing all src/ contents..."

REMOVED_COUNT=0

# Helper function
remove_item() {
  local item="$1"
  if [[ -e "$item" ]]; then
    echo "[reset] - Removing $item"
    rm -rf "$item"
    REMOVED_COUNT=$((REMOVED_COUNT + 1))
  fi
}

# ============================================================
# INFRASTRUCTURE - Remove everything
# ============================================================
echo "[reset] Cleaning infrastructure..."
remove_item "src/infrastructure/main.bicep"
remove_item "src/infrastructure/deploy.sh"
remove_item "src/infrastructure/verify.sh"
remove_item "src/infrastructure/outputs.json"
remove_item "src/infrastructure/generate_outputs.sh"

# ============================================================
# DATA - Remove everything
# ============================================================
echo "[reset] Cleaning data directory..."
remove_item "src/data/README.md"
remove_item "src/data/generate_synthetic_data.py"
remove_item "src/data/generate_data.sh"
remove_item "src/data/prepare_mltables.sh"
remove_item "src/data/raw"
remove_item "src/data/mltable"

# ============================================================
# ML PIPELINE - Remove everything
# ============================================================
echo "[reset] Cleaning ML pipeline..."
remove_item "src/ml-pipeline"

# ============================================================
# DEPLOY - Remove everything
# ============================================================
echo "[reset] Cleaning deployment directory..."
remove_item "src/deploy/env-train.yml"
remove_item "src/deploy/env-infer.yml"
remove_item "src/deploy/score.py"

# ============================================================
# BRUNO - Remove entire collection
# ============================================================
echo "[reset] Cleaning Bruno collection..."
remove_item "bruno/house-price-api"

# ============================================================
# PYTHON CACHE - Remove cache files
# ============================================================
echo "[reset] Cleaning Python cache..."
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -type f -name "*.pyc" -delete 2>/dev/null || true

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    RESET COMPLETE                              ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "[reset] Removed $REMOVED_COUNT items"
echo ""
echo "[reset] Repository is now in pristine state."
echo ""
echo "[reset] Preserved:"
echo "[reset]   ✓ All .github/ artifacts (prompts, context, instructions, copilot-instructions.md)"
echo "[reset]   ✓ Documentation (presentation/, README.md, BRANCH-SETUP-GUIDE.md, etc.)"
echo "[reset]   ✓ Empty directory structure (src/{infrastructure,data,ml-pipeline,deploy}/)"
echo "[reset]   ✓ Empty bruno/ directory"
echo ""
echo "[reset] To regenerate everything, follow:"
echo "[reset]   presentation/DEMO-SCRIPTS.md"
echo ""
echo "[reset] Start with Segment 1 prompts:"
echo "[reset]   #infra-bicep-skeleton"
echo "[reset]   #infra-bicep-refine"
echo "[reset]   #infra-deploy-sh-skeleton"
echo "[reset]   #infra-deploy-sh-refine"
echo ""
