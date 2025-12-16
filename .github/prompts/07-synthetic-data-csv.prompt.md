---
name: synthetic-data-csv
description: Generate synthetic house price CSVs for train/val/test splits
agent: agent
argument-hint: Optionally specify number of rows per split
---

You are helping generate SYNTHETIC tabular data for the house price
scenario described in `src/data/README.md`.

Tasks:

- Create or overwrite three CSV files under `src/data/raw/`:
  - `train.csv`
  - `val.csv`
  - `test.csv`

Data shape and columns:

- Each CSV should have the same schema:
  - `id` (unique integer identifier).
  - `sqft` (int, e.g., 600–4500).
  - `bedrooms` (int, e.g., 1–6).
  - `bathrooms` (float, e.g., 1.0–4.0).
  - `year_built` (int, e.g., 1950–2023).
  - `neighborhood_code` (categorical string, e.g., N1–N5).
  - `garage_spaces` (int, e.g., 0–3).
  - `condition_score` (int, e.g., 1–10).
  - `exterior_type` (categorical string, e.g., brick, siding, stucco, fiber_cement, wood).
  - `price` (float, the target variable, in some realistic local currency).

- Suggested row counts for a fast demo:
  - `train.csv`: ~350 rows.
  - `val.csv`: ~75 rows.
  - `test.csv`: ~75 rows.

Data characteristics:

- Make the data internally consistent:
  - Larger `sqft`, more `bedrooms`, and higher `condition_score`
    should generally correlate with higher `price`.
  - Newer `year_built` should, on average, increase `price`.
  - Different `neighborhood_code` values should shift the base price
    up or down (simulate nicer vs. cheaper areas).

Implementation constraints:

- Write realistic‑looking numeric values that can be parsed by pandas
  without custom logic.
- Ensure the `price` column has some noise so the relationship is not
  perfectly linear.

Important:

- Do NOT print any CSV contents in chat.
- Create the `src/data/raw/` directory if it does not exist, then write
  the three CSV files directly to disk.
- If these files already exist, overwrite them completely.
