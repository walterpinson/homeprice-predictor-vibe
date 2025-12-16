# Vibing Your Way to ML Studio Deployments

- Train a real ML model on your own data.
- Deploy it as a managed online endpoint in Azure ML Studio.
- Do it all from VS Code, with GitHub Copilot vibing the code.

---

# What You’ll See in This Demo

- A live prediction from a real online endpoint.
- A brand‑new Azure ML workspace and infra, created from code.
- A simple house‑price model trained, registered, and deployed.
- GenAI used as an assistant, not a crutch.

---

# The End State (Begin With the End in Mind)

- Managed online endpoint:
  - URL: `https://<endpoint-name>.<region>.inference.ml.azure.com/score`
  - Secured with key or token.
- Request: House features (sqft, beds, baths, etc.).
- Response: Predicted price in the target market.

> First, we’ll call a pre‑built endpoint to see the experience.
> Then we’ll build a fresh environment and re‑create that journey.

---

# Pre‑Flight Check: Infrastructure From Vibes

- Goal: Provision a *new* Azure ML workspace environment from code:
  - Resource group
  - Storage account
  - Key Vault
  - Container registry
  - Application Insights
  - Azure ML workspace
  - AmlCompute cluster
- Tools:
  - Bicep (IaC)
  - Azure CLI (`az`) + Bash (`deploy.sh`)
  - GitHub Copilot for scaffolding and refinement

## Deploy Command

```bash
cd src/infrastructure
./deploy.sh \
  --subscription-id "YOUR_SUBSCRIPTION_ID" \
  --resource-group "rg-ml-demo" \
  --location "eastus" \
  --base-name "mldemo"
```

## Verify Command

```bash
./verify.sh \
  --subscription-id "YOUR_SUBSCRIPTION_ID" \
  --resource-group "rg-ml-demo" \
  --workspace-name "mldemo-mlw" \
  --compute-name "cpu-cluster"
```

---

# How We’ll Use GenAI Here

- Use Copilot to:
  - Draft the Bicep template for the ML workspace stack.
  - Generate the Bash deployment script.
- Use human judgment to:
  - Name resources clearly for the demo.
  - Keep the template minimal but complete.
  - Ensure it runs quickly enough for a live session.

> Vibes for the shape, engineering for the details.
