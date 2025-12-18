# Workspace Prompts

Workspace prompt files live under `.github/prompts/` and can be run in
VS Code Chat by typing `#scenario-house-prices`, `#synthetic-data-csv`,
etc.

---

## Segment 0: Environment Setup

### 00 – Conda Environment for Training

Use this to create `src/deploy/env-train.yml`, a Conda environment
suitable for both local development and Azure ML training jobs.

Prompt file: `.github/prompts/00-conda-env-train.prompt.md`

Command: `#conda-env-train`

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

Use this to generate synthetic train/val/test datasets. Creates a
Python script and bash wrapper that generate three CSV files under
`src/data/raw/` with realistic, correlated house price data (~500
total rows).

Prompt file: `.github/prompts/07-synthetic-data-csv.prompt.md`

Command: `#synthetic-data-csv`

### 08 – MLTable Definitions

Use this to create MLTable definitions for Azure ML data asset
registration. Creates three `MLTable` files under `src/data/mltable/`
and a bash preparation script `src/data/prepare_mltables.sh`.

**Note:** The preparation script is optional since `register_data.sh`
automatically prepares MLTable directories before registration.

Prompt file: `.github/prompts/08-mltable-definitions.prompt.md`

Command: `#mltable-definitions`

---

## Segment 3: Training and Registration Prompts

### 09 – Register MLTable Data Assets

Use this to create `src/ml-pipeline/register_data.py` and
`src/ml-pipeline/register_data.sh`, which register the train/val/test
MLTable assets in the Azure ML workspace.

Prompt file: `.github/prompts/09-register-mltables.prompt.md`

Command: `#register-mltables`

### 10 – Train Script (scikit-learn)

Use this to create `src/ml-pipeline/train.py`, a scikit-learn training
script that reads MLTable-based data, trains a regression model, and
writes `./outputs/model.pkl`.

Prompt file: `.github/prompts/10-train-script-scikit.prompt.md`

Command: `#train-script-scikit`

### 11 – Submit Training Job

Use this to create `src/ml-pipeline/submit_training_job.py` and
`src/ml-pipeline/submit_training_job.sh`, which submit a training job
to Azure ML using the registered data assets and compute cluster.

Prompt file: `.github/prompts/11-submit-training-job.prompt.md`

Command: `#submit-training-job`

### 12 – Register Model Script

Use this to create `src/ml-pipeline/register_model.py`, which registers the
trained model from a completed Azure ML job into the workspace's model
registry.

Prompt file: `.github/prompts/12-register-model-script.prompt.md`

Command: `#register-model-script`

---

## Segment 4: Deployment & Inference Prompts

### 13 – Conda Environment for Inference

Use this to create `src/deploy/env-infer.yml`, a lean Conda environment
for the managed online endpoint with minimal dependencies for fast
cold start.

Prompt file: `.github/prompts/13-conda-env-infer.prompt.md`

Command: `#conda-env-infer`

### 14 – Score Script

Use this to create `src/deploy/score.py`, the scoring entry script used
by the managed online deployment. Implements `init()` and `run(data)`
functions for model loading and inference.

Prompt file: `.github/prompts/14-score-script.prompt.md`

Command: `#score-script`

### 15 – Deploy Online Endpoint

Use this to create `src/ml-pipeline/deploy_model_endpoint.py`, which deploys the
registered model to a managed online endpoint using Azure ML SDK v2.

Prompt file: `.github/prompts/15-deploy-online-endpoint.prompt.md`

Command: `#deploy-online-endpoint`

### 16 – Bruno Collection Setup

Use this to create the Bruno collection metadata and sample environment
file: `bruno/house-price-api/bruno.json` and
`bruno/house-price-api/environments/demo.bru.sample`.

Prompt file: `.github/prompts/16-bruno-collection.prompt.md`

Command: `#bruno-collection-setup`

### 17 – Bruno Requests

Use this to create Bruno request files for calling the house price
endpoint: `predict-basic.bru`, `predict-large-house.bru`,
`predict-fixer-upper.bru`.

Prompt file: `.github/prompts/17-bruno-requests.prompt.md`

Command: `#bruno-requests`
