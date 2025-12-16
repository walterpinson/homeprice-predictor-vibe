#!/usr/bin/env bash
#
# Generate synthetic house price data
#
# Usage:
#   ./generate_data.sh
#
# Or with custom row counts:
#   ./generate_data.sh --train-rows 500 --val-rows 100 --test-rows 100

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================="
echo "Synthetic Data Generation"
echo "========================================="
echo ""

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "Error: python3 is not installed or not in PATH"
    exit 1
fi

# Run the data generation script
cd "$SCRIPT_DIR"
python3 generate_synthetic_data.py "$@"

echo ""
echo "========================================="
echo "Data generation complete!"
echo "========================================="
