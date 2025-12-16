---
name: deploy-online-endpoint
description: Create script to deploy model to a managed online endpoint
agent: agent
argument-hint: Optionally specify default endpoint and deployment names
---

You are helping create a script that DEPLOYS the registered model as
a managed online endpoint in Azure ML.

Task:

- Create or fully overwrite `src/ml-pipeline/deploy_model.py`.

Assumptions:

- A model is already registered in the workspace (e.g.,
  `house-price-regressor`).
- `src/deploy/score.py` exists and will be used as the scoring script.
- `src/deploy/env-infer.yml` defines the inference environment.

Requirements for `deploy_model.py`:

1. Dependencies:
   - Use `azure.ai.ml` (SDK v2) and `azure.identity`:
     - `DefaultAzureCredential`
     - `MLClient`

2. Arguments:
   - Accept command-line arguments:
     - `--subscription-id`
     - `--resource-group`
     - `--workspace-name`
     - `--endpoint-name`
     - `--deployment-name`
     - `--model-name`
     - Optional: `--instance-type` (e.g., `Standard_DS3_v2`)
     - Optional: `--instance-count` (default 1)

3. Behavior:
   - Connect to the workspace via `MLClient`.
   - Retrieve the registered model by name (latest version by default,
     unless you choose to add explicit version support).
   - Define or update:
     - A `ManagedOnlineEndpoint` with the given `endpoint-name`.
     - A `ManagedOnlineDeployment` with:
       - The model.
       - Code configuration pointing at `src/deploy` and `score.py`.
       - An environment created from `env-infer.yml` (local path).
       - Instance type and count from arguments or defaults.
   - If the endpoint already exists, update the deployment instead of
     failing.
   - Route 100% of traffic to this deployment.

4. UX:
   - Print clear log messages, e.g.:
     - `[deploy] Creating or updating endpoint ...`
     - `[deploy] Creating or updating deployment ...`
   - Print the scoring URI and any required headers (e.g., `Authorization`
     with key) as a final summary.

Constraints:

- Follow current Azure ML SDK v2 patterns for managed online endpoints
  and deployments.
- Keep the script focused on a single responsibility: deploying the
  model to an online endpoint.

Important:

- Do NOT print the file contents in chat.
- Write the complete script directly to
  `src/ml-pipeline/deploy_model.py`, overwriting any existing content.
