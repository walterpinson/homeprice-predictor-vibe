# Technical Spec – Vibing Your Way to ML Studio Deployments

## Azure Resources

The Bicep template must provision, as a “comprehensively minimal”
environment:

- Azure Resource Group (per environment).
- Azure Storage Account (Blob) for data and artifacts.
- Azure Key Vault for secrets and connection strings.
- Azure Container Registry for images used by Azure ML.
- Azure Application Insights for logging and telemetry.
- Azure Machine Learning workspace, wired to the above dependencies.
- Azure ML compute cluster (AmlCompute) for training jobs.

Workspace A (pre-existing) and Workspace B (provisioned live) share the
same resource topology but live in separate resource groups.

## Tooling & SDKs

- **Infrastructure & provisioning**
  - Bicep as the IaC language.
  - Azure Resource Manager (ARM) as deployment engine.
  - Azure CLI (`az`) + Bash (`deploy.sh`) to deploy the Bicep templates.

- **ML & code**
  - Python 3.x.
  - Azure ML Python SDK v2 (`azure-ai-ml`) for:
    - Data assets (MLTable).
    - Training jobs (script-based).
    - Model registration.
    - Managed online endpoints and deployments.
  - Azure Identity (`DefaultAzureCredential`) for auth.
  - scikit-learn for the house price model.
  - Conda environment definitions: `env-train.yml` and `env-infer.yml`.

- **Inference & testing**
  - `src/deploy/score.py` as the entry script for online inference.
  - Bruno API client with `.bru` files checked into `bruno/` for
    testing endpoints.

- **Dev environment**
  - VS Code with GitHub Copilot (chat + inline).
  - Git + GitHub with:
    - `main` as canonical source.
    - `demo-ready` as working branch during demo construction.
    - Tags `demo-ready-v1.0` and `demo-start-v1.0`.

## Repository Layout (High-Level)

- `src/infrastructure/`
  - `main.bicep`: defines RG, Storage, Key Vault, ACR, App Insights,
    and Azure ML workspace + compute.
  - `deploy.sh`: Bash script that calls `az` to deploy `main.bicep`.

- `src/ml-pipeline/`
  - `train.py`: trains a regression model on house-price data.
  - `register.py`: registers the trained model in the workspace.
  - `deploy_model_endpoint.py`: creates/updates a managed online endpoint using
    the registered model, `src/deploy/score.py`, and `env-infer.yml`.

- `src/data/`
  - Synthetic CSV/Parquet data.
  - MLTable definitions for train/val/test assets.

- `src/deploy/`
  - `score.py`: Azure ML scoring script for the online endpoint.
  - `env-train.yml` and `env-infer.yml`: conda environments.
  - Optional YAML configs for endpoint/deployment.

- `bruno/`
  - Bruno workspace files and requests for calling the endpoint.

- `presentation/`
  - Markdown slides for each segment and a full combined deck.

- `.github/`
  - `copilot-instructions.md` for repo-wide guidance.
  - `context/` containing this spec, the PRD, and the plan.
  - `instructions/` for path-specific Copilot behaviors.

## Data & Model

- Scenario: House price prediction for a specific market.
- Features (example): `sqft`, `bedrooms`, `bathrooms`, `year_built`,
  `neighborhood_code`, `garage_spaces`, `condition_score`.
- Target: `price`.
- Dataset size: ~500 rows for training to ensure fast runs.
- Splits:
  - Train: ~70%.
  - Validation: ~15%.
  - Test: ~15%.

The model does not need to be state-of-the-art; clarity and speed of
training are more important than accuracy.
