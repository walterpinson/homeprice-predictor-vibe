#!/usr/bin/env bash
#
# prepare_mltables.sh
# Copy CSV files into MLTable directories for self-contained upload to Azure ML
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RAW_DIR="${SCRIPT_DIR}/raw"
MLTABLE_DIR="${SCRIPT_DIR}/mltable"

echo "[prepare] Copying CSV files into MLTable directories..."

# Copy each CSV file into its corresponding MLTable directory
for split in train val test; do
  src="${RAW_DIR}/${split}.csv"
  dest="${MLTABLE_DIR}/${split}/${split}.csv"
  
  if [[ ! -f "$src" ]]; then
    echo "  [ERROR] Source file not found: $src"
    exit 1
  fi
  
  echo "  [copy] ${split}.csv -> mltable/${split}/"
  cp "$src" "$dest"
done

echo "[prepare] ✓ All CSV files copied. MLTable directories are now self-contained."
echo "[prepare] You can now run: cd ../../ml-pipeline && ./register_data.sh"
