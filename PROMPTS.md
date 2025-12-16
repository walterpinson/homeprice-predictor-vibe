# Workspace Prompts

Workspace prompt files live under `.github/prompts/` and can be run in
VS Code Chat by typing `#scenario-house-prices`, `#synthetic-data-csv`,
etc.

---

## Segment 1: Infrastructure Prompts

### 01 – Infra Bicep Skeleton

Use this first to generate `src/infrastructure/main.bicep` from scratch.

Prompt file: `.github/prompts/01-infra-bicep-skeleton.prompt.md`

### 02 – Infra Bicep Refine

Use this to tighten and validate `main.bicep` after the initial scaffold.

Prompt file: `.github/prompts/02-infra-bicep-refine.prompt.md`

### 03 – Infra deploy.sh Skeleton

Use this to generate the first version of
`src/infrastructure/deploy.sh`.

Prompt file: `.github/prompts/03-infra-deploy-sh-skeleton.prompt.md`

### 04 – Infra deploy.sh Refine

Use this to harden `deploy.sh` and print deployment outputs.

Prompt file: `.github/prompts/04-infra-deploy-sh-refine.prompt.md`

### 05 – Infra Verify Script Skeleton

Use this after deployment to generate `src/infrastructure/verify.sh`,
which checks that the workspace and compute cluster exist and are ready.

Prompt file: `.github/prompts/05-infra-verify-script-skeleton.prompt.md`

---

## Segment 2: Scenario and Data Prompts

### 06 – Scenario House Prices

Use this to generate the business narrative for the house price
prediction scenario. Creates `src/data/README.md` with a realistic
story about why a small real‑estate firm needs price predictions.

Prompt file: `.github/prompts/06-scenario-house-prices.prompt.md`

Command: `#scenario-house-prices`

### 07 – Synthetic Data CSV

Use this to generate synthetic train/val/test datasets. Creates three
CSV files under `src/data/raw/` with realistic, correlated house price
data (~500 total rows).

Prompt file: `.github/prompts/07-synthetic-data-csv.prompt.md`

Command: `#synthetic-data-csv`

### 08 – MLTable Definitions

Use this to create MLTable definitions for Azure ML data asset
registration. Creates three `MLTable` files under `src/data/mltable/`
that reference the raw CSV files.

Prompt file: `.github/prompts/08-mltable-definitions.prompt.md`

Command: `#mltable-definitions`
