---
name: reset-demo-script
description: Create a script to reset the repo to the demo start state
agent: agent
argument-hint: Optionally specify which files must never be deleted
---

You are helping create a script that RESETS this repository from a
“demo-ready” state to a “demo-start” state for live presentations.

Task:

- Create or fully overwrite `reset-demo.sh` in the repo root.

Goal:

- When run from the repo root, `reset-demo.sh` should remove all
  generated and solution artifacts that I want to REBUILD live during
  the talk, while keeping all configuration, prompts, infra, and
  presentation files intact.

General behavior:

- Use `#!/usr/bin/env bash` and `set -euo pipefail`.
- Print clear log messages for each action, e.g.
  `[reset] Removing file ...`.
- At the end, print a short summary of what was removed and a reminder
  to re-run the demo steps.

Files and folders to PRESERVE (do NOT delete):

- Infrastructure code:
  - `src/infrastructure/**` (Bicep, deploy scripts, verify scripts)
  - Note: `outputs.json` will be regenerated, so it's safe to remove
- Training environment:
  - `src/deploy/env-train.yml` (training environment)
- Bruno API testing:
  - `bruno/house-price-api/bruno.json`
  - `bruno/house-price-api/environments/demo.bru.sample`
  - `bruno/house-price-api/*.bru` (request files)
  - Note: `demo.bru` contains secrets and should be removed
- Prompts and documentation:
  - `.github/prompts/**`
  - `.github/context/**`
  - `.github/copilot-instructions.md`
  - `presentation/**`
  - `PROMPTS.md` (in presentation folder)
  - `README.md`
  - `DEMO-SCRIPTS.md` (in presentation folder)
  - `LICENSE`
  - `.gitignore`

Files and artifacts to REMOVE (these will be re-created during the demo):

- Data generation scripts:
  - `src/data/generate_synthetic_data.py`
  - `src/data/generate_data.sh`
- ML pipeline scripts:
  - `src/ml-pipeline/register_data.py`
  - `src/ml-pipeline/register_data.sh`
  - `src/ml-pipeline/train.py`
  - `src/ml-pipeline/submit_training_job.py`
  - `src/ml-pipeline/submit_training_job.sh`
  - `src/ml-pipeline/register_model.py`
  - `src/ml-pipeline/register_model.sh`
  - `src/ml-pipeline/deploy_model_endpoint.py`
  - `src/ml-pipeline/deploy_model_endpoint.sh`
- Deployment artifacts:
  - `src/deploy/score.py`
  - `src/deploy/env-infer.yml`
- Data artifacts:
  - `src/data/raw/*.csv` (synthetic data)
  - `src/data/mltable/train/*` (MLTable definitions)
  - `src/data/mltable/val/*`
  - `src/data/mltable/test/*`
  - `src/data/prepare_mltables.sh`
  - `src/data/README.md` (scenario narrative, regenerated from prompt)
- Infrastructure outputs:
  - `src/infrastructure/outputs.json` (regenerated on deploy)
  - `src/infrastructure/generate_outputs.sh` (if present)
- Bruno secrets:
  - `bruno/house-price-api/environments/demo.bru` (contains API keys)
- Python cache and temporary files:
  - `**/__pycache__/`
  - `**/*.pyc`

Implementation details:

- Use `rm -f` for individual files, `rm -rf` for directories, guarded
  with `[[ -e path ]]` checks where appropriate to avoid noisy errors.
- Optionally, accept a `--dry-run` flag that prints what WOULD be
  removed without actually deleting anything.

Important:

- Do NOT print the script contents in chat.
- Write the complete Bash script directly into `reset-demo.sh` at the
  repo root, overwriting any existing content.
- Make sure the script is safe to run multiple times (idempotent).
- Make the script executable (`chmod +x reset-demo.sh`).