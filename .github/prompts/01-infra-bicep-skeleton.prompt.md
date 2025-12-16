---
name: infra-bicep-skeleton
description: Scaffold a minimal Azure ML workspace Bicep template
agent: ask
argument-hint: Optionally describe any extra constraints for the infra
---

You are helping me build a minimal but complete Azure Machine Learning
infrastructure using Bicep for this workspace:

- Repo root: ${workspaceFolder}
- Target file: src/infrastructure/main.bicep

Assume there is no existing infra code; we are starting from scratch.

Goal:
Create a new Bicep template for a "comprehensively minimal" Azure ML
environment for a demo:

- The deployment scope is a resource group (the RG will be created by CLI).
- Resources to create:
  - Storage account (Blob) for data and artifacts.
  - Key Vault for secrets.
  - Application Insights for logging.
  - Azure Container Registry (ACR) for images.
  - Azure Machine Learning workspace wired to those resources.
  - Azure ML AmlCompute cluster for training.

Constraints:

- Use parameters for:
  - `location` (default to resourceGroup().location).
  - `baseName` (prefix for naming resources).
  - AmlCompute settings (vm size, min/max nodes, idle time).
- Use reasonable, demo‑friendly SKUs:
  - Storage: Standard_LRS.
  - ACR: Basic.
  - App Insights: web application type.
- Use current, valid API versions for:
  - Storage account.
  - Key Vault.
  - Application Insights.
  - Container Registry.
  - Azure ML workspace and computes.

Deliverables:

1. Generate the full content of `src/infrastructure/main.bicep` that:
   - Declares the necessary parameters.
   - Defines each required resource.
   - Wires the workspace to storage, key vault, app insights, and ACR via IDs.
   - Defines a single AmlCompute cluster attached to the workspace.

2. Include outputs for:
   - Workspace name and ID.
   - Storage account name.
   - Key Vault name.
   - Container registry name.
   - Application Insights name.

Style:

- Add concise comments above major sections to make this template easy
  to explain in a live tech talk.
- Avoid advanced features like VNets or private endpoints.

Deliverable:

- Write the complete Bicep template directly to `src/infrastructure/main.bicep`.
- Do NOT return the code in the chat window.
- Confirm the file was created successfully.
