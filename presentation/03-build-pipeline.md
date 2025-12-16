# From Data to Model

- We now have:
  - A realistic house price scenario.
  - Synthetic train/val/test data.
  - MLTable definitions for Azure ML.
- Next step: turn this into a trained, registered model.

> This is where vibes meet deterministic ML.

---

# How We'll Train

- Use Azure ML Python SDK v2:
  - Submit a script‑based training job.
  - Run on the AmlCompute cluster we provisioned.
- Use a simple, fast model:
  - scikit‑learn regression (e.g., LinearRegression or RandomForestRegressor).
  - Train in a few seconds on ~500 rows.

> The focus is the **process**, not squeezing out every last RMSE point.

---

# Training Script Responsibilities

- Read MLTable data assets (train and val).
- Split features/target (X, y).
- Train the model.
- Evaluate on validation data (basic metrics).
- Save the trained model to `./outputs` so Azure ML captures it.

> `./outputs` is the contract between your script and Azure ML jobs.

---

# Registering the Model

- After the job completes:
  - The trained model artifact lives in the job's outputs.
- Registration with Azure ML Python SDK:
  - Create a `Model` object pointing to the job output.
  - Tag it with:
    - Scenario name.
    - Data version.
    - Training code version (git commit hash, optional).

> Registration turns "a file in a run" into a reusable asset.

---

# What This Enables Next

- A registered model can be:
  - Attached to an online endpoint.
  - Versioned and rolled back.
  - Shared across teams and environments.
- This sets the stage for:
  - `score.py` and the managed online endpoint.
  - Bruno tests against a real API.

> Once the model is registered, deployment becomes a configuration problem.
