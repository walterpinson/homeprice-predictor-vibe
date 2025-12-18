---
name: mltable-definitions
description: Create MLTable definitions for train/val/test data assets
agent: agent
argument-hint: Optionally specify Azure ML datastore name
---

You are helping define MLTable assets for Azure ML to consume the
synthetic house price data.

Assumptions:

- Synthetic CSVs already exist at:
  - `src/data/raw/train.csv`
  - `src/data/raw/val.csv`
  - `src/data/raw/test.csv`

Tasks:

1. Create or overwrite three MLTable definition directories under
   `src/data/mltable/`:
   - `src/data/mltable/train/MLTable`
   - `src/data/mltable/val/MLTable`
   - `src/data/mltable/test/MLTable`

2. Create a bash preparation script at `src/data/prepare_mltables.sh` that:
   - Copies CSV files from `src/data/raw/` to their respective MLTable
     directories (e.g., `train.csv` → `mltable/train/train.csv`)
   - This ensures MLTable files can use local relative paths like
     `./train.csv` instead of `../../raw/train.csv`
   - Uses clear logging messages
   - Creates directories as needed
   - Example structure:
     ```bash
     #!/usr/bin/env bash
     set -euo pipefail
     
     echo "[mltable] Preparing MLTable directories..."
     mkdir -p src/data/mltable/{train,val,test}
     cp src/data/raw/train.csv src/data/mltable/train/
     cp src/data/raw/val.csv src/data/mltable/val/
     cp src/data/raw/test.csv src/data/mltable/test/
     echo "[mltable] CSV files copied to MLTable directories."
     ```

Requirements for each MLTable:

- Reference the corresponding CSV file using a local relative path
  (e.g., `./train.csv`, `./val.csv`, `./test.csv`) since the prep
  script will copy CSVs into each MLTable directory.
- Use simple schema inference (we do not need to hard‑code every column).
- Use the standard Azure ML v2 MLTable format so that:
  - We can register them as data assets using the Azure ML Python SDK
    (`azure-ai-ml`).
  - They work for training and evaluation without special options.

Example structure (adapt, do not literally copy):

- Specify the file(s) under a `paths` section.
- Optionally specify `transformations` if needed, but keep it minimal.

Important:

- Do NOT print the MLTable file contents or bash script in chat.
- Create any missing directories (`src/data/mltable/train`, etc.).
- Write directly to each `MLTable` file and the `prepare_mltables.sh`
  script, overwriting any existing content.
- Make the bash script executable.
- After creation, users should run `./prepare_mltables.sh` to copy
  CSV files into MLTable directories before registering data assets.
