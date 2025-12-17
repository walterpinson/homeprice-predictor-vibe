# Demo Scripts – Vibing Your Way to ML Studio Deployments

This file is the **step-by-step sequence** for the live demo.
Each section maps to a talk segment and specifies:

- Where to act (Copilot Chat, Terminal, Bruno, Portal).
- Which prompt names to invoke.
- Which commands to run.

Replace `<SUB_ID>`, resource group, workspace, etc. with your actual values.

---

## Prereqs (before the talk)

- Repo checked out (ideally at `demo-start-v1.0`).
- Conda installed.
- Azure CLI installed and `az login` already done.
- Bruno installed.

Optional but recommended: run `conda env create -f src/deploy/env-train.yml`
before the session so env creation doesn't eat live time.

---

## Segment 1 – Infra Pre-flight (Bicep + Deploy)

**Goal:** Show that a fresh Azure ML workspace + compute can be provisioned from code.

### 1.1 – Use Copilot to scaffold and refine infra (you may skip live if already generated)

In **Copilot Chat (VS Code)**:

- Run: `#infra-bicep-skeleton`
- Run: `#infra-bicep-refine`
- Run: `#infra-deploy-sh-skeleton`
- Run: `#infra-deploy-sh-refine`
- Run: `#infra-verify-script-skeleton` (if you created this prompt)

These will (re)create:

- `src/infrastructure/main.bicep`
- `src/infrastructure/deploy.sh`
- `src/infrastructure/verify.sh`

### 1.2 – Deploy infra

In **Terminal** (from repo root):

```bash
cd src/infrastructure

chmod +x deploy.sh
./deploy.sh \
  --subscription-id "<SUB_ID>" \
  --resource-group "rg-ml-vibe-demo-01" \
  --location "eastus" \
  --base-name "vibedemo-01"
```

Optional: show outputs in terminal.

### 1.3 – Verify infra

```bash
chmod +x verify.sh
./verify.sh \
  --subscription-id "<SUB_ID>" \
  --resource-group "rg-ml-vibe-demo-01" \
  --workspace-name "vibedemo-01-mlw" \
  --compute-name "cpu-cluster"

cd ../..
```

You can also briefly show the workspace and compute in the Azure ML portal.

---

## Segment 2 – Vibing the Scenario & Data

**Goal:** Turn a business "vibe" into a concrete scenario + synthetic data + MLTable definitions.

### 2.1 – Scenario narrative

In **Copilot Chat**:

- Run: `#scenario-house-prices`

This creates/overwrites `src/data/README.md`.

In **VS Code Editor**:

- Open `src/data/README.md` and read a few lines to the audience.

### 2.2 – Synthetic data generation

In **Copilot Chat**:

- Run: `#synthetic-data-csv`

This creates:

- `src/data/raw/train.csv`
- `src/data/raw/val.csv`
- `src/data/raw/test.csv`

Optional, in **Terminal**:

```bash
ls src/data/raw
head -n 5 src/data/raw/train.csv
```

### 2.3 – MLTable definitions

In **Copilot Chat**:

- Run: `#mltable-definitions`

This creates:

- `src/data/mltable/train/MLTable`
- `src/data/mltable/val/MLTable`
- `src/data/mltable/test/MLTable`

---

## Segment 3 – Train & Register the Model

**Goal:** Register data, submit a training job, and register the trained model.

### 3.0 – Activate training environment

In **Terminal** (once per machine):

```bash
conda env create -f src/deploy/env-train.yml   # if not created yet
conda activate vibe-ml-train                   # or the name in env-train.yml
```

### 3.1 – Register MLTable data assets

In **Copilot Chat** (if needed):

- Run: `#register-mltables` (creates `src/ml-pipeline/register_data.py`)

In **Terminal**:

```bash
cd src/ml-pipeline

./register_data.sh \
  --base-data-name "house-prices"

cd ../..
```

### 3.2 – Create training script

In **Copilot Chat** (if needed):

- Run: `#train-script-scikit` (creates `src/ml-pipeline/train.py`)

Optional, in **VS Code Editor**:

- Open `src/ml-pipeline/train.py` and briefly highlight:
  - Data loading.
  - Model training.
  - Saving `./outputs/model.pkl`.

### 3.3 – Create submission helper

In **Copilot Chat** (if needed):

- Run: `#submit-training-job` (creates submission scripts)
  - This should create:
    - `src/ml-pipeline/submit_training_job.py`
    - `src/ml-pipeline/submit_training_job.sh`

### 3.4 – Submit training job

In **Terminal**:

```bash
cd src/ml-pipeline

./submit_training_job.sh \
  --compute-name "cpu-cluster" \
  --experiment-name "house-prices-train"

cd ../..
```

Wait for the job to complete. You can:

- Show job status in portal, or
- Use the job name from output for next step.

Make a note of the **job name** (e.g., `mango_wheel_ccndwnzp0f`).

### 3.5 – Register the trained model

In **Copilot Chat** (if needed):

- Run: `#register-model-script` (creates `src/ml-pipeline/register_model.py`)

In **Terminal**:

```bash
cd src/ml-pipeline

./register_model.sh \
  --job-name "<TRAINING_JOB_NAME_FROM_3.4>" \
  --model-name "house-pricing-01"

cd ../..
```

Optional: show the model in Azure ML portal under **Models**.

---

## Segment 4 – Deploy Endpoint & Test with Bruno

**Goal:** Deploy the registered model as a managed online endpoint and hit it live from Bruno.

### 4.0 – Ensure training env active

In **Terminal**:

```bash
conda activate vibe-ml-train
```

### 4.1 – Inference environment & scoring script

In **Copilot Chat** (if needed):

- Run: `#conda-env-infer` (creates/updates `src/deploy/env-infer.yml`)
- Run: `#score-script` (creates/updates `src/deploy/score.py`)

Optional, in **VS Code Editor**:

- Briefly show `score.py` and explain `init()` and `run()`.

### 4.2 – Deployment script

In **Copilot Chat** (if needed):

- Run: `#deploy-online-endpoint` (creates deployment scripts)

### 4.3 – Deploy managed online endpoint

In **Terminal**:

```bash
cd src/ml-pipeline

./deploy_model_endpoint.sh \
  --model-name "house-pricing-01" \
  --model-version 1 \
  --endpoint-name "house-pricing-ep-01"

cd ../..
```

Wait for the script to complete. It should print the scoring URL and primary key.

**Note:** If you need to rebuild the environment (e.g., after updating dependencies):

```bash
cd src/ml-pipeline

./deploy_model_endpoint.sh \
  --model-name "house-pricing-01" \
  --model-version 1 \
  --endpoint-name "house-pricing-ep-01" \
  --env-version 2 \
  --force-env-rebuild

cd ../..
```

### 4.4 – Set up Bruno collection & environment

In **Copilot Chat** (if needed):

- Run: `#bruno-collection-setup` (creates `bruno/house-price-api/bruno.json` and `demo.bru.sample`)
- Run: `#bruno-requests` (creates `predict-*.bru` requests)

In **Terminal**:

```bash
cp bruno/house-price-api/environments/demo.bru.sample \
   bruno/house-price-api/environments/demo.bru
```

In **VS Code Editor**:

- Open `bruno/house-price-api/environments/demo.bru` and set:

  ```
  vars {
    baseUrl: https://<your-endpoint-host>
    apiKey: <your-primary-key>
  }
  ```

**Important:** Do not include comments in the file - Bruno won't recognize the environment with comments present.

### 4.5 – Hit the endpoint from Bruno

In **Bruno**:

1. Open collection: `bruno/house-price-api`.
2. Select `demo` environment from the dropdown.
3. Run:
   - `predict-basic`
   - `predict-large-house`
   - `predict-fixer-upper`

Show predictions changing as you tweak inputs.

---

## Segment 5 – Wrap-up & Q&A

No new commands required. Use this time to:

- Flip through Segment 5 slides.
- Show the repo structure in VS Code one last time (infra → data → pipeline → deploy → Bruno).
- Invite questions.

---

## Resetting After a Dry Run

When you finish a full rehearsal and want to reset to a "demo-start" state:

In **Terminal** (from repo root):

```bash
./reset-demo.sh
git status
# Optionally commit if you want to create a new demo-start tag
```

Then repeat the full flow using this DEMO-SCRIPTS.md and adjust as you find friction points.
