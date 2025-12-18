---
name: submit-training-job
description: Create a script to submit training jobs to Azure ML
agent: agent
argument-hint: Optionally specify compute cluster, environment, or experiment name
---

You are helping create a script that SUBMITS a training job to Azure ML.

Task:

- Create or fully overwrite `src/ml-pipeline/submit_training_job.py`.
- Create or fully overwrite `src/ml-pipeline/submit_training_job.sh` (a bash
  wrapper script).

Assumptions:

- The Azure ML workspace and AmlCompute cluster already exist.
- MLTable data assets have been registered (e.g., `house-prices-train`,
  `house-prices-val`, `house-prices-test`).
- The training script `train.py` exists in `src/ml-pipeline/`.
- A training environment configuration exists at `src/deploy/env-train.yml`.

Requirements for `submit_training_job.py`:

1. Dependencies:
   - Use `azure.ai.ml` (Python SDK v2) and `azure.identity`:
     - `DefaultAzureCredential`
     - `MLClient`
     - `command` function for creating jobs
     - `Input` for data references

2. Arguments:
   - Accept command-line arguments:
     - `--subscription-id`
     - `--resource-group`
     - `--workspace-name`
     - `--compute-cluster` (name of the AmlCompute cluster)
     - `--base-data-name` (default: `house-prices`)
     - `--experiment-name` (default: `house-price-training`)
     - `--environment-file` (path to env-train.yml, default:
       `../deploy/env-train.yml`)

3. Behavior:
   - Connect to the workspace using `MLClient`.
   - Create a `command` job that:
     - Uses the specified compute cluster.
     - References the training environment from `env-train.yml`.
     - Runs `train.py` with arguments:
       - `--train-data` pointing to the registered train data asset
       - `--val-data` pointing to the registered val data asset
       - `--target-column price`
     - Uses `Input` objects with type `mltable` for data references.
   - Submit the job using `ml_client.jobs.create_or_update(...)`.
   - Print the job name/ID and a link to view it in Azure ML Studio.
   - Optionally, stream job logs to stdout.

4. UX:
   - Print clear messages:
     - `[job] Submitting training job to Azure ML ...`
     - `[job] Job submitted: <job-name>`
     - `[job] View in Studio: <studio-url>`
   - Provide the job name so it can be used for model registration.

Constraints:

- Follow Azure ML SDK v2 patterns for job submission.
- Keep the script focused on job submission; it should not contain
  training logic.
- Use the `command` function to create a CommandJob.
- Reference data assets by name and version (e.g., `azureml:house-prices-train:1`
  or use latest version).

Requirements for `submit_training_job.sh`:

1. Purpose:
   - Provide a convenient wrapper around `submit_training_job.py`.
   - Read Azure configuration from the infrastructure deployment outputs.

2. Behavior:
   - Source or read the deployment outputs from
     `src/infrastructure/outputs.json` (created by `deploy.sh`).
   - Extract:
     - Subscription ID
     - Resource group name
     - Workspace name
   - Determine the compute cluster name (could be hardcoded as
     `demo-cluster` or read from outputs if available).
   - Invoke `submit_training_job.py` with these values.
   - Pass through any additional arguments to override defaults.

3. UX:
   - Print a header indicating job submission is starting.
   - Display the job name/ID after submission.
   - Make the script executable and include a shebang.

Important:

- Do NOT print the file content in chat.
- Write the complete script directly to `src/ml-pipeline/submit_training_job.py`,
  overwriting any existing content.
- Write the complete script directly to `src/ml-pipeline/submit_training_job.sh`,
  overwriting any existing content.
