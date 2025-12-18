---
name: conda-env-train
description: Create a Conda environment file for local dev and training jobs
agent: agent
argument-hint: Optionally specify Python or scikit-learn versions
---

You are helping define the Conda environment for this project's
HOUSE PRICE training workflow.

Task:

- Create or fully overwrite `src/deploy/env-train.yml`.

Goals:

- The same Conda environment should work for:
  - Local development on my machine (running `register_data.py`,
    `train.py`, `register_model.py` directly).
  - Azure ML training jobs that use `train.py` and the Azure ML
    Python SDK v2.

Requirements for `env-train.yml`:

- Use a standard Conda YAML structure with:
  - A `name` (e.g., `vibe-ml-train`).
  - Channels including at least `conda-forge` (and `defaults` if needed).
  - `dependencies` that include:
    - Python 3.10 or 3.11 (version that works well with azure-ai-ml).
    - `numpy`
    - `pandas`
    - `scikit-learn`
    - `joblib` (or ensure scikit-learn's deps cover it)
    - `mltable` (for loading Azure ML MLTable data assets)
    - `pip`
    - Under `pip:`:
      - `azure-ai-ml`
      - `azure-identity`
      - (Optionally) `mlflow` if helpful for basic logging, but it's not required.

Constraints:

- Keep versions reasonably current and mutually compatible.
- Do not include heavy, unnecessary packages that would slow down
  environment creation (keep it lean for a demo).

Usage expectations (for humans):

- Locally, I will run:
  - `conda env create -f src/deploy/env-train.yml`
  - `conda activate vibe-ml-train`
- In Azure ML, I may reference this file when defining a custom
  environment for jobs.

Important:

- Do NOT print the file contents in chat.
- Write the complete YAML directly into `src/deploy/env-train.yml`,
  overwriting any existing content.
