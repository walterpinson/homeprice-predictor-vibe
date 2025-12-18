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
  └─ demo-infra-YYYY-MM-DD   # Points to specific clean infrastructure
       │                      # Example: demo-infra-2025-01-15
       │
       ├─ demo-segment-1      # Post-infrastructure (outputs.json created)
       │
       ├─ demo-segment-2      # Post-data generation (CSVs, MLTables exist)
       │
       ├─ demo-segment-3      # Post-training (model registered)
       │
       └─ demo-segment-4      # Post-deployment (endpoint created, not tested)
```

---

## One-Time Setup: Create Clean Infrastructure

Before each presentation, deploy fresh Azure ML infrastructure to a dedicated resource group:

### 1. Create Resource Group

```bash
# Use date-based naming for traceability
DATE=$(date +%Y-%m-%d)
RG_NAME="rg-ml-demo-${DATE}"
LOCATION="eastus"
BASE_NAME="demo${DATE//-/}"  # Removes hyphens for Azure naming

az group create \
  --name "$RG_NAME" \
  --location "$LOCATION"
```

### 2. Deploy Infrastructure

```bash
cd src/infrastructure

./deploy.sh \
  --subscription-id "$AZURE_SUBSCRIPTION_ID" \
  --resource-group "$RG_NAME" \
  --location "$LOCATION" \
  --base-name "$BASE_NAME"

cd ../..
```

**Expected output:** `outputs.json` with workspace details

### 3. Verify Infrastructure

```bash
cd src/infrastructure

./verify.sh \
  --subscription-id "$AZURE_SUBSCRIPTION_ID" \
  --resource-group "$RG_NAME" \
  --workspace-name "${BASE_NAME}-mlw" \
  --compute-name "cpu-cluster"

cd ../..
```

### 4. Create Infrastructure Branch

```bash
# Create branch pointing to this infrastructure
git checkout -b "demo-infra-${DATE}"
git add src/infrastructure/outputs.json
git commit -m "chore(infra): add outputs for $RG_NAME infrastructure"
git push origin "demo-infra-${DATE}"
```

---

## Creating Segment Checkpoints

Use the infrastructure branch as your starting point:

### Segment 1: Post-Infrastructure

```bash
# Start from clean infrastructure
git checkout "demo-infra-${DATE}"
git checkout -b demo-segment-1

# No changes needed - outputs.json already exists
git push origin demo-segment-1
```

**State:**
- ✅ Infrastructure deployed
- ✅ `outputs.json` exists
- ❌ No data artifacts
- ❌ No ML pipeline scripts

---

### Segment 2: Post-Data Generation

```bash
# Start from segment 1
git checkout demo-segment-1
git checkout -b demo-segment-2

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
git add src/data/
git commit -m "chore(data): add generated data for segment 2 checkpoint"
git push origin demo-segment-2
```

**State:**
- ✅ Infrastructure deployed
- ✅ Data generated (CSVs, MLTables)
- ❌ No training jobs
- ❌ No models registered

---

### Segment 3: Post-Training

```bash
# Start from segment 2
git checkout demo-segment-2
git checkout -b demo-segment-3

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
git add src/ml-pipeline/
git commit -m "chore(training): add training scripts and registered model for segment 3"
git push origin demo-segment-3
```

**State:**
- ✅ Infrastructure deployed
- ✅ Data generated
- ✅ Model trained and registered
- ❌ No endpoint deployed

---

### Segment 4: Post-Deployment

```bash
# Start from segment 3
git checkout demo-segment-3
git checkout -b demo-segment-4

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
git commit -m "chore(deploy): add deployment scripts and endpoint for segment 4"
git push origin demo-segment-4
```

**State:**
- ✅ Infrastructure deployed
- ✅ Data generated
- ✅ Model trained and registered
- ✅ Endpoint deployed (may still be warming up)

---

## Creating Demo-Ready Branch

This branch has a fully working endpoint for the opening demo:

```bash
# Use segment-4 as base
git checkout demo-segment-4

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

### Segment 1: Infrastructure Overview

```bash
# Stay on demo-ready or switch to demo-segment-1
git checkout demo-segment-1  # If you want clean slate
```

Show Bicep files, explain deployment, show workspace in portal.

---

### Segment 2: Live Data Generation

```bash
# Option A: Continue from segment 1
# (if you ran prompts and generated data)

# Option B: Switch to checkpoint
git checkout demo-segment-2
```

Run prompts #06, #07, #08 to generate data (if starting fresh).

---

### Segment 3: Live Training

```bash
# Option A: Continue from segment 2
# (if you successfully generated data)

# Option B: Switch to checkpoint
git checkout demo-segment-3
```

Run prompts #09-#12 to train and register model (if starting fresh).

---

### Segment 4: Live Deployment

```bash
# Option A: Continue from segment 3
# (if you successfully trained model)

# Option B: Switch to checkpoint
git checkout demo-segment-4
```

Run prompts #13-#15 to deploy endpoint (if starting fresh).

---

## Resetting Between Demos

After completing a presentation, reset the working directory for next practice run:

```bash
# Reset to clean state (removes generated artifacts)
./reset-demo.sh

# Optionally commit the reset state
git add -A
git commit -m "chore: reset to demo-start state"

# Push if you want to preserve this checkpoint
git push origin demo-segment-1  # Or whichever segment you're on
```

---

## Quick Reference

### Before Demo Day

1. Deploy clean infrastructure → `demo-infra-YYYY-MM-DD`
2. Create segment checkpoints → `demo-segment-1` through `demo-segment-4`
3. Test opening demo → `demo-ready` with working endpoint
4. Practice transitions between segments

### During Demo

- **Opening:** `demo-ready` (show working endpoint)
- **Segment 1:** `demo-segment-1` (show infra code)
- **Segment 2:** Continue or switch to `demo-segment-2`
- **Segment 3:** Continue or switch to `demo-segment-3`
- **Segment 4:** Continue or switch to `demo-segment-4`

### After Demo

```bash
./reset-demo.sh          # Clean up generated files
git checkout main        # Return to baseline
```

---

## Cleanup Old Infrastructure

After demos, clean up Azure resources:

```bash
# List all demo resource groups
az group list --query "[?starts_with(name, 'rg-ml-demo-')].name" -o table

# Delete specific demo infrastructure
az group delete --name "rg-ml-demo-2025-01-15" --yes --no-wait

# Delete corresponding git branch (optional)
git branch -d demo-infra-2025-01-15
git push origin --delete demo-infra-2025-01-15
```

---

## Tips for Success

1. **Test segment transitions** before live demos
2. **Keep Bruno environment file** (demo.bru) out of version control (contains secrets)
3. **Use date-based naming** for infrastructure to avoid conflicts
4. **Practice checkpoint switches** to build muscle memory
5. **Have demo-ready loaded in Bruno** before presentation starts
6. **Know which branch has which state** - print this guide as reference
7. **Pre-warm endpoints** before demos (they can take 5-10 minutes to deploy)

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
# Manually edit outputs.json to point to correct infrastructure
# Or re-run deploy.sh to regenerate it
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
