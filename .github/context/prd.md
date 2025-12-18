# Product Requirements (PRD) – Vibing Your Way to ML Studio Deployments

## Goal

Show an end-to-end, code-first Azure ML deployment using “vibe coding”
with GitHub Copilot inside VS Code, targeted at practitioners who are
GenAI-curious but not yet fluent in MLOps.

## User Story

As a technical attendee, I want to see a realistic ML model trained on
my own (or synthetic) data and deployed to Azure ML Studio as a managed
online endpoint, so that I understand how accessible MLOps can be when
assisted by GenAI tools.

## Key Requirements

- Use a **house price prediction** scenario that feels like a real
  business problem.
- Demonstrate **live training** of a model on roughly 500 rows with
  6–8 features, completing in under ~10 seconds.
- Use a **train/validation/test split** for the data, and explain the
  purpose of each subset.
- Use **two distinct Azure ML workspaces**:
  - Workspace A: pre-existing, used only for the very first “live
    inference hook” demo.
  - Workspace B: created during the session via Bicep + Bash and used
    for all subsequent demos.
- Use **code-first workflows only** (no manual Portal setup) for:
  - Infrastructure (Bicep + Azure CLI).
  - Data registration (MLTable).
  - Training, model registration, and endpoint creation (Python SDK).
- Show inference using a **Git-tracked API client** (Bruno) instead of
  curl, with `.bru` files checked into the repo.
- Allow the talk to be delivered entirely inside **VS Code** (multipane:
  markdown, code, terminal, Copilot chat), with optional brief views of
  the Azure ML Studio portal and Bruno UI.

## Non-Goals

- No deep dive into ML theory (only light explanation of the chosen
  model).
- No advanced networking or VNet isolation scenarios.
- No complex CI/CD pipelines; focus on the developer inner loop.

## Success Criteria

- The full demo can be run end-to-end from a clean `demo-start` state in
  under 30 minutes.
- All steps are automatable and reproducible from the repository.
- Attendees leave believing they could adapt the repo and flow to their
  own use case.
