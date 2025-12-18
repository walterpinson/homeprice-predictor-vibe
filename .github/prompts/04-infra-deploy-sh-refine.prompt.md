---
name: infra-deploy-sh-refine
description: Harden deploy.sh and print deployment outputs
agent: agent
argument-hint: Optionally specify which outputs matter most to you
---

We already have a draft `src/infrastructure/deploy.sh` script in this
workspace. It parses arguments, sets the subscription, creates the
resource group, and runs `az deployment group create`.

Your job is to refine it for a polished live-demo experience.

Goals:

1. Robustness:
   - Verify that `az` is installed; if not, print a clear error and exit.
   - Verify that the user is logged in (`az account show`) and fail with
     a helpful message if not.
   - Check the result of the resource group creation and exit on failure.

2. Deployment outputs:
   - After a successful `az deployment group create`, call
     `az deployment group show` to retrieve the deployment outputs.
   - Print a short summary including:
     - Workspace name.
     - Storage account name.
     - Key Vault name.
     - Container registry name.
     - Application Insights name.
     - Compute cluster name.
   - Assume the Bicep template defines these as outputs.
   - Capture these outputs to a JSON file at `outputs.json` in the same
     directory with the following structure:
     {
       "subscriptionId": "<subscription-id>",
       "resourceGroup": "<resource-group>",
       "location": "<location>",
       "workspaceName": "<workspace-output>",
       "storageAccountName": "<storage-output>",
       "keyVaultName": "<keyvault-output>",
       "containerRegistryName": "<acr-output>",
       "appInsightsName": "<appinsights-output>",
       "computeCluster": "<compute-output>"
     }
   - Use `jq` or `az --query` to parse the deployment outputs cleanly.
   - This file will be used by downstream ML pipeline scripts to avoid
     requiring the user to pass workspace details repeatedly.

3. Developer experience:
   - Use clear, prefixed log lines like:
     - `[deploy] Creating resource group ...`
     - `[deploy] Running Bicep deployment ...`
   - Keep the script small, readable, and easy to narrate live.

Instructions:

- Read the existing `src/infrastructure/deploy.sh` in this workspace.
- Produce an improved version that incorporates these enhancements.
- Preserve the existing flag structure and overall purpose.
- Write the updated script directly to `src/infrastructure/deploy.sh`.
- Ensure the file remains executable.
- Do NOT return the code in the chat window.
- Confirm the file was updated successfully.
