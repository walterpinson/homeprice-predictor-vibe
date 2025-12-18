---
name: infra-deploy-sh-skeleton
description: Scaffold a Bash script to deploy the Bicep template with az CLI
agent: agent
argument-hint: Optionally specify default values for RG, location, base name
---

You are helping me create a Bash script that deploys the Bicep template
for the Azure ML infra.

Target file:
- `src/infrastructure/deploy.sh`

Assumptions:

- The user has the Azure CLI installed and has already run `az login`.
- The resource group may or may not exist; the script should create it
  if needed.
- The Bicep file lives at `src/infrastructure/main.bicep`.

Requirements:

1. Argument handling:
   - Accept the following flags:
     - `--subscription-id`
     - `--resource-group`
     - `--location`
     - `--base-name`
   - Validate that all required arguments are provided; if any are
     missing, print a clear usage message and exit with a nonzero code.

2. Behavior:
   - Use `#!/usr/bin/env bash` and `set -euo pipefail`.
   - Set the subscription with `az account set`.
   - Create the resource group if it does not exist.
   - Run `az deployment group create` against `main.bicep`, passing the
     parameters:
     - `location`
     - `baseName`

3. Demo‑friendly UX:
   - Print clear status messages before each major step.
   - Include a usage example in comments at the top of the script.

Deliverable:

- Write the complete script directly to `src/infrastructure/deploy.sh`.
- Make the file executable with `chmod +x src/infrastructure/deploy.sh`.
- Do NOT return the code in the chat window.
- Confirm the file was created successfully.
