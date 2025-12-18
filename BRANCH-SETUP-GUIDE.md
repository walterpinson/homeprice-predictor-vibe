# Branch Setup Guide for Demo Presentations

This guide explains how to create and maintain git branch checkpoints for smooth, fail-safe live demonstrations.

---

## Strategy Overview

Use **git branches** to create segment checkpoints that allow you to:
- Start each segment from a known-good state
- Handle audience questions without time pressure
- Recover from demo issues by switching branches
- Practice individual segments independently

---

## Branch Structure

```
main                     # Stable baseline
  │
  ├─ demo-ready          # Complete working demo with deployed endpoint
  │                      # Used for opening inference demo
  │
  └─ demo-segment-1      # Pre-infrastructure (clean slate)
       │                 # - reset-demo.sh has been run
       │                 # - infrastructure scripts ready but not executed
       │                 # - no outputs.json
       │                 # - no Azure resource group or infrastructure
       │
       ├─ demo-segment-2      # Post-infrastructure (outputs.json created)
       │                      # Azure RG: rg-mlvibes-02
       │
       ├─ demo-segment-3      # Post-data generation (CSVs, MLTables exist)
       │                      # Azure RG: rg-mlvibes-03
       │
       └─ demo-segment-4      # Post-training (mltables and models registered)
                              # Azure RG: rg-mlvibes-04
```

**Note:** Each segment branch (except demo-segment-1) is associated with a dedicated Azure resource group that reflects the infrastructure state for that segment's starting point.

---

## One-Time Setup: Create Demo-Segment-1 Branch

Before creating segment checkpoints, establish the clean starting point with infrastructure scripts ready but not executed:

### 1. Reset to Clean State

```bash
# Ensure you're on main or a clean branch
git checkout main

# Run reset script to remove generated artifacts
./reset-demo.sh
```

### 2. Create Demo-Segment-1 Branch

```bash
# Create the pre-infrastructure checkpoint
git checkout -b demo-segment-1
git add -A
git commit -m "chore(demo): create segment-1 starting point (pre-infrastructure)"
git push origin demo-segment-1
```

**State:**
- ✅ Infrastructure scripts in place (`src/infrastructure/*.bicep`, `deploy.sh`, `verify.sh`)
- ✅ Clean workspace (no generated artifacts)
- ❌ No `outputs.json` file
- ❌ No Azure resource group
- ❌ No Azure infrastructure deployed

---

## Creating Segment Checkpoints

Use demo-segment-1 as your starting point:

### Segment 2: Post-Infrastructure

```bash
# Start from clean slate
git checkout demo-segment-1
git checkout -b demo-segment-2

# Deploy Azure ML infrastructure
RG_NAME="rg-mlvibes-02"
LOCATION="eastus"
BASE_NAME="mlvibes02"

# Create resource group
az group create --name "$RG_NAME" --location "$LOCATION"

# Deploy infrastructure
cd src/infrastructure
./deploy.sh \
  --subscription-id "$AZURE_SUBSCRIPTION_ID" \
  --resource-group "$RG_NAME" \
  --location "$LOCATION" \
  --base-name "$BASE_NAME"
cd ../..

# Commit the outputs.json
git add src/infrastructure/outputs.json
git commit -m "chore(infra): add outputs for rg-mlvibes-02 infrastructure"
git push origin demo-segment-2
```

**State:**
- ✅ Infrastructure deployed to Azure (resource group: `rg-mlvibes-02`)
- ✅ `outputs.json` exists
- ❌ No data artifacts
- ❌ No ML pipeline scripts

---

### Segment 3: Post-Data Generation

```bash
# Start from segment 2
git checkout demo-segment-2
git checkout -b demo-segment-3

# Optional: Deploy to dedicated resource group for this segment
# This allows segment 3 to have independent infrastructure
RG_NAME="rg-mlvibes-03"
LOCATION="eastus"
BASE_NAME="mlvibes03"

az group create --name "$RG_NAME" --location "$LOCATION"
cd src/infrastructure
./deploy.sh \
  --subscription-id "$AZURE_SUBSCRIPTION_ID" \
  --resource-group "$RG_NAME" \
  --location "$LOCATION" \
  --base-name "$BASE_NAME"
cd ../..

# Generate data using prompts
# In VS Code Copilot Chat:
#   #scenario-house-prices
#   #synthetic-data-csv

cd src/data
./generate_data.sh
cd ../..

# In VS Code Copilot Chat:
#   #mltable-definitions

# Commit the generated artifacts
git add src/data/ src/infrastructure/outputs.json
git commit -m "chore(data): add generated data for segment 3 checkpoint"
git push origin demo-segment-3
```

**State:**
- ✅ Infrastructure deployed (resource group: `rg-mlvibes-03`)
- ✅ Data generated (CSVs, MLTables)
- ❌ No training jobs
- ❌ No models registered

---

### Segment 4: Post-Training

```bash
# Start from segment 3
git checkout demo-segment-3
git checkout -b demo-segment-4

# Optional: Deploy to dedicated resource group for this segment
RG_NAME="rg-mlvibes-04"
LOCATION="eastus"
BASE_NAME="mlvibes04"

az group create --name "$RG_NAME" --location "$LOCATION"
cd src/infrastructure
./deploy.sh \
  --subscription-id "$AZURE_SUBSCRIPTION_ID" \
  --resource-group "$RG_NAME" \
  --location "$LOCATION" \
  --base-name "$BASE_NAME"
cd ../..

# Re-register data assets in new workspace
cd src/ml-pipeline
./register_data.sh --base-data-name "house-prices"
cd ../..

# Generate ML pipeline scripts using prompts
# In VS Code Copilot Chat:
#   #register-mltables
#   #train-script-scikit
#   #submit-training-job
#   #register-model-script

# Register data assets
cd src/ml-pipeline
./register_data.sh --base-data-name "house-prices"

# Submit training job
./submit_training_job.sh \
  --compute-name "cpu-cluster" \
  --experiment-name "house-prices-train"

# Wait for job to complete (check portal or CLI)
# Get job name from output, then register model
./register_model.sh \
  --job-name "<TRAINING_JOB_NAME>" \
  --model-name "house-pricing-01"

cd ../..

# Commit the generated scripts
git add src/ml-pipeline/ src/infrastructure/outputs.json
git commit -m "chore(training): add training scripts and registered model for segment 4"
git push origin demo-segment-4
```

**State:**
- ✅ Infrastructure deployed (resource group: `rg-mlvibes-04`)
- ✅ Data generated
- ✅ Model trained and registered
- ✅ MLTables and models registered in Azure ML
- ❌ No endpoint deployed

---

## Creating Demo-Ready Branch

This branch has a fully working endpoint for the opening demo

:

```bash
# Start from segment 4
git checkout demo-segment-4

# Generate deployment scripts using prompts
# In VS Code Copilot Chat:
#   #conda-env-infer
#   #score-script
#   #deploy-online-endpoint

# Deploy endpoint
cd src/ml-pipeline
./deploy_model_endpoint.sh \
  --model-name "house-pricing-01" \
  --model-version 1 \
  --endpoint-name "house-pricing-ep-01"
cd ../..

# Commit the deployment artifacts
git add src/deploy/ src/ml-pipeline/deploy_model_endpoint.*
git commit -m "chore(deploy): add deployment scripts and endpoint for demo-ready"

# Wait for endpoint to be fully ready
# Test with Bruno to confirm it works

# Create demo-ready branch
git checkout -b demo-ready
git push origin demo-ready
```

**Configure Bruno for testing:**

```bash
# Copy sample environment
cp bruno/house-price-api/environments/demo.bru.sample \
   bruno/house-price-api/environments/demo.bru

# Edit demo.bru with endpoint URL and key from deployment output
# Get values from: src/ml-pipeline/deploy_model_endpoint.sh output
```

**Test all Bruno requests:**
- `predict-basic.bru`
- `predict-large-house.bru`
- `predict-fixer-upper.bru`

Once confirmed working, this branch is ready for opening demos.

---

## Using Branches During Demo

### Opening: Show Working Inference

```bash
git checkout demo-ready
```

Open Bruno, run requests against deployed endpoint.

---

### Segment 1: Infrastructure Deployment

```bash
# Start from pre-infrastructure checkpoint
git checkout demo-segment-1
```

Show Bicep files, explain infrastructure, then deploy live or switch to demo-segment-2 to show deployed infrastructure.

---

### Segment 2: Live Data Generation

```bash
# Option A: Continue from segment 1 if infrastructure deployed
# (or if you deployed during segment 1)

# Option B: Switch to checkpoint with infrastructure ready
git checkout demo-segment-2
```

Run prompts to generate data (if starting fresh), or switch to demo-segment-3 to show generated data.

---

### Segment 3: Live Training

```bash
# Option A: Continue from segment 2 if data generated
# (or if you generated data during segment 2)

# Option B: Switch to checkpoint with data ready
git checkout demo-segment-3
```

Run prompts to train and register model (if starting fresh), or switch to demo-segment-4 to show registered model.

---

### Segment 4: Live Deployment

```bash
# Option A: Continue from segment 3 if model trained
# (or if you trained model during segment 3)

# Option B: Switch to checkpoint with trained model
git checkout demo-segment-4
```

Run prompts to deploy endpoint (if starting fresh), or switch to demo-ready to show working endpoint.

---

## Resetting Between Demos

Two reset options are available:

### Quick Reset (Preserves Infrastructure)

After completing a presentation, reset the working directory for next practice run:

```bash
# Reset to clean state (removes generated artifacts, preserves infrastructure)
./reset-demo.sh

# Optionally commit the reset state
git add -A
git commit -m "chore: reset to demo-start state"

# Push if you want to preserve this checkpoint
git push origin demo-segment-1  # Or whichever segment you're on
```

### Complete Reset (New User Setup)

For new users or creating a pristine demo-segment-1 branch:

```bash
# Complete reset - removes ALL generated files including infrastructure
./reset.sh

# Create fresh demo-segment-1 branch
git checkout -b demo-segment-1
git add -A
git commit -m "chore(demo): create pristine segment-1 starting point"
git push origin demo-segment-1
```

**Key Differences:**
- `reset-demo.sh`: Preserves infrastructure (Bicep, deploy scripts, env-train.yml)
- `reset.sh`: Removes everything that can be regenerated from Copilot prompts

---

## Quick Reference

### Before Demo Day

1. Create clean starting point → `demo-segment-1` (pre-infrastructure)
2. Create segment checkpoints → `demo-segment-2` (post-infra), `demo-segment-3` (post-data), `demo-segment-4` (post-training)
3. Create and test opening demo → `demo-ready` with working endpoint
4. Practice transitions between segments

### During Demo

- **Opening:** `demo-ready` (show working endpoint)
- **Segment 1:** `demo-segment-1` (deploy infrastructure) → can switch to `demo-segment-2` if needed
- **Segment 2:** `demo-segment-2` (generate data) → can switch to `demo-segment-3` if needed
- **Segment 3:** `demo-segment-3` (train model) → can switch to `demo-segment-4` if needed
- **Segment 4:** `demo-segment-4` (deploy endpoint) → can switch to `demo-ready` if needed

### After Demo

```bash
./reset-demo.sh          # Quick reset (preserves infrastructure)
# OR
./reset.sh               # Complete reset (removes everything)

git checkout main        # Return to baseline
```

---

## Cleanup Old Infrastructure

After demos, clean up Azure resources:

```bash
# List all demo resource groups
az group list --query "[?starts_with(name, 'rg-mlvibes-')].name" -o table

# Delete segment-specific infrastructure
az group delete --name "rg-mlvibes-02" --yes --no-wait
az group delete --name "rg-mlvibes-03" --yes --no-wait
az group delete --name "rg-mlvibes-04" --yes --no-wait

# Or delete all at once
for rg in rg-mlvibes-02 rg-mlvibes-03 rg-mlvibes-04; do
  az group delete --name "$rg" --yes --no-wait
done
```

---

## Tips for Success

1. **Test segment transitions** before live demos
2. **Keep Bruno environment file** (demo.bru) out of version control (contains secrets)
3. **Use consistent resource group naming** (`rg-mlvibes-02`, `rg-mlvibes-03`, `rg-mlvibes-04`) for each segment
4. **Practice checkpoint switches** to build muscle memory
5. **Have demo-ready loaded in Bruno** before presentation starts
6. **Know which branch has which state** - print this guide as reference
7. **Pre-warm endpoints** before demos (they can take 5-10 minutes to deploy)
8. **Deploy infrastructure in background** while using demo-ready for opening - switch to demo-segment-2 when ready
9. **Each segment can have independent infrastructure** - useful for parallel development or recovery scenarios

---

## Troubleshooting

**Problem:** Branch won't switch due to uncommitted changes

```bash
# Stash changes temporarily
git stash

# Switch branch
git checkout demo-segment-2

# Restore changes if needed
git stash pop
```

**Problem:** outputs.json points to wrong resource group

```bash
# Check which resource group each segment should use:
# - demo-segment-2 → rg-mlvibes-02
# - demo-segment-3 → rg-mlvibes-03
# - demo-segment-4 → rg-mlvibes-04

# Manually edit outputs.json to point to correct infrastructure
# Or re-run deploy.sh to regenerate it with the correct resource group
```

**Problem:** Endpoint deployment takes too long during demo

- Use pre-deployed endpoint from `demo-ready` branch
- Show deployment code but don't wait for completion
- Reference opening demo: "You saw this working at the start"

---

## Summary

This branch strategy provides:
- ✅ **Safety:** Known-good checkpoints at each segment
- ✅ **Flexibility:** Switch branches if time runs short
- ✅ **Practice:** Rehearse individual segments independently
- ✅ **Recovery:** Fail forward instead of debugging live
- ✅ **Confidence:** Opening demo proves everything works

Use these branches to make your demo **bulletproof**.
