---
name: register-model-script
description: Create a script to register the trained model in Azure ML
agent: agent
argument-hint: Optionally specify default model name or tags
---

You are helping create a script that REGISTERS the trained model
artifact from a completed Azure ML job into the workspace model registry.

Task:

- Create or fully overwrite `src/ml-pipeline/register_model.py`.

Assumptions:

- The model was trained by a job that ran `train.py` and saved a model
  artifact to `./outputs/model.pkl`.
- We know:
  - The Azure subscription.
  - The resource group.
  - The workspace name.
  - The job name or job ID.

Requirements for `register_model.py`:

1. Dependencies:
   - Use `azure.ai.ml` (Python SDK v2) and `azure.identity` for auth:
     - `DefaultAzureCredential` for credentials.
     - `MLClient` to connect to the workspace.

2. Arguments:
   - Accept command‑line arguments:
     - `--subscription-id`
     - `--resource-group`
     - `--workspace-name`
     - `--job-name`
     - `--model-name` (e.g., `house-price-regressor`)
     - Optional: `--model-version-tag` or similar for key metadata.

3. Behavior:
   - Connect to the workspace using `MLClient` + `DefaultAzureCredential`.
   - Locate the job's output model path:
     - Use the job details to find the `outputs` location.
     - Point the model registration at the correct URI (e.g., job output
       in Azure ML storage).
   - Create or update a `Model` in the registry using `ml_client.models.create_or_update(...)`:
     - Set `name` from `--model-name`.
     - Attach tags (scenario, data version, etc.) if provided.

4. UX:
   - Print a clear success message with:
     - Registered model name.
     - Registered model version.
   - Print helpful errors if the job or outputs cannot be found.

Constraints:

- Use the SDK v2 patterns from the latest Azure ML docs.
- Keep the script focused on a single responsibility: registering the
  model from a given job.

Important:

- Do NOT print the file content in chat.
- Write the complete script directly to `src/ml-pipeline/register_model.py`,
  overwriting any existing content.
