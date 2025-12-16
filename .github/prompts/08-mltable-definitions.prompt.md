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

- Create or overwrite three MLTable definition directories under
  `src/data/mltable/`:
  - `src/data/mltable/train/MLTable`
  - `src/data/mltable/val/MLTable`
  - `src/data/mltable/test/MLTable`

Requirements for each MLTable:

- Reference the corresponding CSV file using a relative path from
  the MLTable file.
- Use simple schema inference (we do not need to hard‑code every column).
- Use the standard Azure ML v2 MLTable format so that:
  - We can register them as data assets using the Azure ML Python SDK
    (`azure-ai-ml`).
  - They work for training and evaluation without special options.

Example structure (adapt, do not literally copy):

- Specify the file(s) under a `paths` section.
- Optionally specify `transformations` if needed, but keep it minimal.

Important:

- Do NOT print the MLTable file contents in chat.
- Create any missing directories (`src/data/mltable/train`, etc.).
- Write directly to each `MLTable` file, overwriting any existing content.
