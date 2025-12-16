---
name: infra-verify-script-skeleton
description: Create a Bash script that verifies the Azure ML infra using az and az ml
agent: ask
argument-hint: Optionally specify workspace and compute naming conventions
---

You are helping me create a Bash script to VERIFY that a previously
deployed Azure ML infrastructure is healthy.

Target file:
- `src/infrastructure/verify.sh`

Assumptions:

- The Bicep template has already been deployed using `deploy.sh`.
- The user has the Azure CLI installed, with the ML extension (v2) and
  is logged in (`az login` done).
- The Azure ML workspace and its dependent resources already exist.

Requirements:

1. Argument handling:
   - Accept the following flags:
     - `--subscription-id`
     - `--resource-group`
     - `--workspace-name`
     - `--compute-name`
   - Validate that all are provided; if any are missing, print a clear
     usage message and exit with a nonzero code.

2. Behavior:
   - Use `#!/usr/bin/env bash` and `set -euo pipefail`.
   - Set the subscription with `az account set`.
   - Verify the workspace exists:
     - Use `az ml workspace show -n <workspace> -g <rg>`.
     - Fail with a clear message if the workspace is not found.
   - Verify the compute exists:
     - Use `az ml compute show -n <compute> --workspace-name <workspace> -g <rg>`.
     - Fail with a clear message if it is not found.
   - Optionally, verify basic properties:
     - Print workspace location and resource group.
     - Print compute size and current provisioning state.

3. Demo‑friendly UX:
   - Print clear, prefixed log lines, e.g.:
     - `[verify] Checking workspace ...`
     - `[verify] Checking compute cluster ...`
   - At the end, print a simple success summary indicating that the
     environment is ready for training and deployment.

Deliverable:

- Write the complete script directly to `src/infrastructure/verify.sh`.
- Make the file executable with `chmod +x src/infrastructure/verify.sh`.
- Do NOT return the code in the chat window.
- Confirm the file was created successfully.

NOTE: Do NOT run any verification commands yourself; just create the script.
The user will execute it manually from the terminal.
