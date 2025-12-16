# Build & Demo Plan – Vibing Your Way to ML Studio Deployments

## Phase 1 – Infrastructure

1. Author `src/infrastructure/main.bicep` to create:
   - RG, Storage, Key Vault, ACR, App Insights, AML workspace, AmlCompute.
2. Author `src/infrastructure/deploy.sh` to:
   - Accept parameters (subscription, location, env name).
   - Run `az group create` and `az deployment group create` for Bicep.
3. Validate against a test subscription and record expected outputs.

## Phase 2 – Data & Scenario

1. Use GitHub Copilot prompts to:
   - Generate a realistic house-price business scenario.
   - Generate synthetic data (train/val/test) matching the spec.
2. Store data under `src/data/` and define MLTable assets.
3. Confirm data can be registered and accessed from Azure ML.

## Phase 3 – Training & Registration

1. Implement `train.py`:
   - Load MLTable data.
   - Train a scikit-learn regression model quickly (< 10 seconds).
   - Log basic metrics.
   - Save model to `./outputs` for AML to capture.
2. Implement `register.py`:
   - Register the trained model in the workspace model registry.

## Phase 4 – Deployment & Inference

1. Implement `src/deploy/score.py`:
   - `init()` loads the registered model.
   - `run(inputs)` accepts JSON and returns predictions.
2. Implement `deploy_model.py`:
   - Create managed online endpoint (idempotent).
   - Create/update deployment using model + `score.py` + `env-infer.yml`.
3. Create a Bruno collection under `bruno/`:
   - Environment for base URL and key.
   - 2–3 sample prediction requests.

## Phase 5 – Presentation Content

1. Author markdown slides under `presentation/`:
   - Segment 1: Hook + infrastructure.
   - Segment 2: Vibing the scenario.
   - Segment 3: Build (train + register).
   - Segment 4: Deploy + inference.
   - Segment 5: Narrative + takeaways.
2. Create `PROMPTS.md` with all Copilot prompts used.
3. Create `DEMO-SCRIPTS.md` with the exact terminal commands and sequence.

## Phase 6 – Demo States

1. On `demo-ready`:
   - Ensure full end-to-end flow works.
   - Tag as `demo-ready-v1.0`.
2. Run `reset-demo.sh` to clear solution code (but keep infra, prompts,
   presentation).
3. Commit the reset state and tag as `demo-start-v1.0`.
4. Merge `demo-ready` into `main` so `main` reflects the fully working
   version.
