---
name: synthetic-data-csv
description: Generate synthetic house price CSVs for train/val/test splits
agent: agent
argument-hint: Optionally specify number of rows per split
---

You are helping generate SYNTHETIC tabular data for the house price
scenario described in `src/data/README.md`.

This is a two-step process:

## Step 1: Create the data generation script

Create a Python script at `src/data/generate_synthetic_data.py` that:

- Generates three CSV files under `src/data/raw/`:
  - `train.csv` (~350 rows)
  - `val.csv` (~75 rows)
  - `test.csv` (~75 rows)

The script should:
- Use a fixed random seed for reproducibility
- Accept optional command-line arguments for row counts (with defaults)
- Create the `src/data/raw/` directory if it doesn't exist
- Write CSV files with proper headers

## Step 2: Create a bash wrapper script

Create a bash script at `src/data/generate_data.sh` that:

- Uses `#!/usr/bin/env bash` shebang
- Sets `set -euo pipefail` for safety
- Runs the Python script with appropriate defaults
- Includes error handling and clear log messages
- Makes it easy to regenerate data during the demo
- Example usage:
  ```bash
  #!/usr/bin/env bash
  set -euo pipefail
  
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  
  echo "[data] Generating synthetic house price data..."
  python3 "$SCRIPT_DIR/generate_synthetic_data.py"
  echo "[data] Data generation complete."
  ```

Data shape and columns:

Each CSV must have this exact schema:
- `id` (unique integer identifier)
- `sqft` (int, e.g., 600–4500)
- `bedrooms` (int, e.g., 1–6)
- `bathrooms` (float, e.g., 1.0–4.0)
- `year_built` (int, e.g., 1950–2023)
- `neighborhood_code` (categorical string: N1, N2, N3, N4, N5)
- `garage_spaces` (int, e.g., 0–3)
- `condition_score` (int, e.g., 1–10)
- `exterior_type` (categorical string: brick, siding, stucco, fiber_cement, wood)
- `price` (float, the target variable in USD)

Data generation requirements:

The Python script must create realistic, correlated data:

- **Square footage → bedrooms**: Larger homes should have more bedrooms
  (e.g., 1500 sqft ≈ 2-3 bedrooms, 3000 sqft ≈ 4-5 bedrooms)

- **Square footage → price**: Strong positive correlation
  (primary price driver)

- **Year built → price**: Newer homes should generally cost more
  (subtle age depreciation effect)

- **Condition score → price**: Higher condition = higher price
  (significant impact, e.g., condition 9-10 adds 15-20% premium)

- **Neighborhood code → price**: Different base price levels
  - N1: Premium area (highest base prices)
  - N2: High-end area (second highest)
  - N3: Mid-range
  - N4: Affordable (lower base prices)
  - N5: Up-and-coming (moderate)

- **Exterior type → price**: Subtle quality premiums
  - brick: +8% premium (highest quality)
  - fiber_cement: +5% premium
  - stucco: +2% premium
  - siding: baseline
  - wood: -2% (requires more maintenance)

- **Garage spaces → price**: Each space adds ~4% to price

- **Bathrooms**: Should correlate with bedrooms (roughly 0.75 * bedrooms)

- **Price noise**: Add ±10% random variation to make relationships
  non-linear and realistic (simulates market variability)

Implementation details:

- Use realistic Boulder, CO market prices (base around $350K-$550K
  depending on neighborhood)
- Ensure all numeric values can be parsed by pandas without special handling
- Use standard Python libraries (csv, random, argparse, os)
- No external dependencies beyond Python standard library

Important:

- Do NOT print CSV contents or full Python code in chat
- Create both `src/data/generate_synthetic_data.py` and 
  `src/data/generate_data.sh` using the create_file tool
- Make the bash script executable (chmod +x)
- After creating the scripts, inform the user they can run:
  `cd src/data && ./generate_data.sh` to generate the CSV files
