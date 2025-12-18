# Vibing Your Way to ML Studio Deployments

A demonstration project showing how to use GitHub Copilot and VS Code workspace prompts to rapidly build and deploy an end-to-end Azure ML solution.

## Overview

This repository demonstrates a complete ML workflow from infrastructure provisioning to model deployment:

- **Infrastructure as Code**: Bicep templates for Azure ML workspace, compute, and supporting services
- **Data Generation**: Synthetic house price data with realistic correlations
- **Training Pipeline**: scikit-learn model training on Azure ML compute
- **Model Deployment**: Managed online endpoint with scoring script
- **API Testing**: Bruno collection for testing the deployed endpoint

## Quick Start

### Prerequisites

- Azure subscription with appropriate permissions
- Azure CLI (`az`) installed and authenticated (`az login`)
- Python 3.8+ with conda
- Bruno (for API testing)
- VS Code with GitHub Copilot

### Demo Workflow

Follow the complete step-by-step demo in:
- **[presentation/DEMO-SCRIPTS.md](presentation/DEMO-SCRIPTS.md)** - Detailed demo execution guide
- **[presentation/PROMPTS.md](presentation/PROMPTS.md)** - Workspace prompt reference

### Resetting the Demo

To reset the repository from a "demo-ready" state back to "demo-start" state:

```bash
# Preview what would be removed
./reset-demo.sh --dry-run

# Actually reset to demo-start state
./reset-demo.sh
```

**What gets removed:**
- ML pipeline scripts (register_data, train, submit_training_job, register_model, deploy_model_endpoint)
- Generated data artifacts (CSV files, MLTable definitions)
- Infrastructure outputs (outputs.json)
- Bruno secrets (demo.bru with API keys)
- Python cache files

**What gets preserved:**
- Infrastructure code (Bicep templates, deploy scripts)
- Deployment scaffolding (env-train.yml, env-infer.yml, score.py)
- Data generation scripts (generate_data.sh, generate_synthetic_data.py)
- Bruno collection structure
- All prompts and documentation

After resetting, follow [presentation/DEMO-SCRIPTS.md](presentation/DEMO-SCRIPTS.md) to rebuild the demo.

## Repository Structure

```
.github/
  prompts/           # VS Code workspace prompts (#infra-bicep-skeleton, etc.)
  context/           # Supporting context (PRD, spec, plan)
bruno/
  house-price-api/   # Bruno API testing collection
presentation/        # Demo scripts, slides, and documentation
src/
  data/              # Data generation and MLTable definitions
  deploy/            # Scoring script and conda environments
  infrastructure/    # Bicep templates and deployment scripts
  ml-pipeline/       # Training, registration, and deployment scripts
```

## Presentation Materials

The demo is structured in five segments, each with corresponding slides:

1. **[Segment 1: Hook - Infrastructure](presentation/01-hook-infrastructure.md)** - Azure ML workspace provisioning with Bicep
2. **[Segment 2: Vibe the Scenario](presentation/02-vibe-scenario.md)** - Business narrative and synthetic data generation
3. **[Segment 3: Build the Pipeline](presentation/03-build-pipeline.md)** - Training jobs and model registration
4. **[Segment 4: Deploy the Endpoint](presentation/04-deploy-endpoint.md)** - Managed online endpoint deployment and testing
5. **[Segment 5: Narrative & Takeaways](presentation/05-narrative-takeaways.md)** - Project summary and methodology

## Documentation

- **[presentation/DEMO-SCRIPTS.md](presentation/DEMO-SCRIPTS.md)** - Step-by-step demo execution guide
- **[presentation/PROMPTS.md](presentation/PROMPTS.md)** - Workspace prompt reference
- **[.github/context/prd.md](.github/context/prd.md)** - Project requirements
- **[.github/context/spec.md](.github/context/spec.md)** - Technical specification
- **[.github/context/plan.md](.github/context/plan.md)** - Implementation plan

## License

See [LICENSE](LICENSE) for details.
