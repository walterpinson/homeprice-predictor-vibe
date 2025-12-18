# What We Just Built

- Started from a vibe: “Help a small investor predict house prices.”
- Turned that into:
  - Azure ML workspace + compute, provisioned from Bicep.
  - Synthetic train/val/test data + MLTable assets.
  - A trained and registered regression model.
  - A managed online endpoint serving real-time predictions.
  - Bruno requests hitting the endpoint like any production client.

> From zero to a live ML API without leaving VS Code.

---

# Vibe Coding → Context Engineering

- Vibe coding gave us:
  - Fast scenario creation and synthetic data.
  - First drafts of infra, scripts, and prompts.
- Context engineering made it real:
  - PRD, spec, and plan files.
  - Copilot instructions + prompt files.
  - Reproducible scripts for deploy, train, register, and serve.

> The magic wasn’t just “ask the AI,” it was how we structured its context.

---

# Why Azure ML Managed Endpoints?

- Handle the heavy lifting:
  - Hosting, scaling, and auth for your model.[web:132][web:129]
  - Logging and monitoring through Azure Monitor.[web:170][web:173]
- Fit naturally into MLOps:
  - Model registry, versioning, and rollbacks.[web:97]
  - Ability to add deployments and shift traffic as you evolve the model.[web:132][web:176]

> You focus on your model and data; the platform handles the plumbing.

---

# What You Can Reuse Tomorrow

- Repo structure:
  - Infra (`main.bicep`, `deploy.sh`, `verify.sh`).
  - Data (`mltable/`), training, registration, deployment scripts
