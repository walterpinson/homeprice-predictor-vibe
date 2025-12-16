---
name: register-mltables
description: Register train/val/test MLTable data assets in Azure ML
agent: agent
argument-hint: Optionally specify default data asset names or version tags
---

You are helping create a script that REGISTERS the MLTable-based data
assets (train/val/test) into the Azure ML workspace.

Task:

- Create or fully overwrite `src/ml-pipeline/register_data.py`.

Assumptions:

- Local MLTable definitions already exist at:
  - `src/data/mltable/train/MLTable`
  - `src/data/mltable/val/MLTable`
  - `src/data/mltable/test/MLTable`
- We want to register each as a named data asset in the workspace.

Requirements for `register_data.py`:

1. Dependencies:
   - Use `azure.ai.ml` (Python SDK v2) and `azure.identity`:
     - `DefaultAzureCredential`
     - `MLClient`

2. Arguments:
   - Accept command-line arguments:
     - `--subscription-id`
     - `--resource-group`
     - `--workspace-name`
     - `--datastore-name` (optional; if omitted, use the default workspace datastore).
     - Optional: `--base-data-name` (e.g., `house-prices`).

3. Behavior:
   - Connect to the workspace using `MLClient`.
   - For each split (train, val, test):
     - Create a `Data` asset of type `mltable` pointing to the local
       MLTable directory under `src/data/mltable/<split>`.
     - Use names like:
       - `<base-data-name>-train`
       - `<base-data-name>-val`
       - `<base-data-name>-test`
       where `<base-data-name>` defaults to `house-prices` if not
       provided.
     - Use `ml_client.data.create_or_update(...)` to register them.
   - Print the registered data asset names and versions.

4. UX:
   - Log clear messages for each split:
     - `[data] Registering train data asset ...`
     - `[data] Registering val data asset ...`
     - `[data] Registering test data asset ...`
   - On success, print a short summary of all three assets.

Constraints:

- Follow current Azure ML SDK v2 patterns for MLTable data registration.
- Keep the script focused on data registration; it should not run any
  training.

Important:

- Do NOT print the file content in chat.
- Write the complete script directly to `src/ml-pipeline/register_data.py`,
  overwriting any existing content.
