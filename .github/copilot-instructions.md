You are assisting with a live demo project called
“Vibing Your Way to ML Studio Deployments”.

Before generating or editing nontrivial code, Bicep, Bash, or
documentation, conceptually read:

- .github/context/prd.md
- .github/context/spec.md
- .github/context/plan.md

Key principles:

- Use Azure ML workspace + managed online endpoints with:
  - Storage, Key Vault, ACR, App Insights, AmlCompute.
- Favor fast, simple, scikit-learn models on ~500 rows of
  house-price data.
- Keep training jobs under ~10 seconds.
- All infrastructure should be defined in Bicep and deployed via
  Azure CLI + Bash scripts.
- Use `src/deploy/score.py` as the scoring entry script for online
  endpoints and keep it simple and robust.
- Use Bruno (files under `bruno/`) for calling the online endpoint.

When generating code, follow the repository layout described in
spec.md and the phases described in plan.md. Prefer clear, didactic
code with comments suitable for live explanation.

When working under `src/infrastructure/`:

- Assume Bicep is the source of truth for Azure resources.
- Follow the dependencies model: storage, key vault, ACR,
  App Insights, then workspace, then AmlCompute.
- Keep templates small and demo‑friendly (no advanced networking).
