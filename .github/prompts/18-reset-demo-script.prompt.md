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

- All files under:
  - `.github/`
  - `src/infrastructure/` (infra is vibed and tested already)
  - `src/deploy/` (env-train.yml, env-infer.yml, score.py)
  - `bruno/` (collections and .bru.sample files)
  - `presentation/`
- `PROMPTS.md`
- `README.md`
- `DEMO-SCRIPTS.md`
- License and .gitignore

Files and artifacts to REMOVE (these will be re-created during the demo):

- Training & data scripts:
  - `src/ml-pipeline/register_data.py`
  - `src/ml-pipeline/train.py`
  - `src/ml-pipeline/submit_training_job.py`
  - `src/ml-pipeline/submit_training_job.sh`
  - `src/ml-pipeline/register.py`
  - `src/ml-pipeline/deploy_model.py`
- Any generated synthetic data and MLTable materialization artifacts:
  - `src/data/raw/*.csv`
  - `src/data/mltable/**` (MLTable definitions can be regenerated)
- Any Python cache and temporary files:
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