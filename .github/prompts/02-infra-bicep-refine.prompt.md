---
name: infra-bicep-refine
description: Refine and harden the Azure ML workspace Bicep template
agent: ask
argument-hint: Optionally mention subscription/region or extra constraints
---

We already have an initial `src/infrastructure/main.bicep` file in this
workspace. Your job is to refine and harden it for a real demo.

Context:

- The template should provision:
  - Storage account.
  - Key Vault.
  - Application Insights.
  - Container Registry.
  - Azure ML workspace.
  - AmlCompute cluster.

Tasks:

1. Validate and, if necessary, update API versions to current, supported
   ones for:
   - Storage.
   - Key Vault.
   - Application Insights.
   - Container Registry.
   - Azure ML workspaces and computes.

2. Ensure all required properties are present:
   - Storage: `sku`, `kind`, and basic settings.
   - Key Vault: tenant ID, SKU, and appropriate access configuration
     (RBAC or access policies suitable for a simple demo).
   - App Insights: `Application_Type` set to `web`.
   - ACR: SKU and `adminUserEnabled`.
   - Workspace: references to storage, key vault, app insights, and ACR
     via `id`.
   - AmlCompute: `computeType` set to `AmlCompute`, `vmSize`, and
     `scaleSettings` with min/max nodes and idle timeout.

3. Improve naming patterns:
   - Storage account: lowercase, globally unique‑friendly using `baseName`.
   - Other resources: follow a `${baseName}-suffix` convention where
     appropriate.

4. Keep the template demo‑friendly:
   - No VNets or private endpoints.
   - No advanced diagnostics beyond what's needed.

Instructions:

- Read the existing `src/infrastructure/main.bicep` in this workspace.
- Produce an updated version that is ready to deploy with a single
  `az deployment group create` command into an empty resource group.
- Add short comments before major sections to aid live explanation.
- Return only the improved Bicep code to replace the file.
