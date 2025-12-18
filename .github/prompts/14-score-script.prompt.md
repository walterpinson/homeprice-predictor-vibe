---
name: score-script
description: Create score.py entry script for the managed online endpoint
agent: agent
argument-hint: Optionally specify the feature order or logging preferences
---

You are helping create the SCORING SCRIPT for the managed online
endpoint.

Task:

- Create or fully overwrite `src/deploy/score.py`.

Assumptions:

- The model is a scikit-learn regressor registered in Azure ML.
- At deployment time, Azure ML will mount the model under
  `AZUREML_MODEL_DIR`.
- The model expects the same features as the synthetic data:
  - `sqft`
  - `bedrooms`
  - `bathrooms`
  - `year_built`
  - `neighborhood_code`
  - `garage_spaces`
  - `condition_score`
  - `exterior_type` (categorical; encode simply for demo purposes)

Requirements for `score.py`:

1. Structure:
   - Define `init()`:
     - Read `AZUREML_MODEL_DIR` from environment.
     - Load the model (e.g., `model.pkl`) using `joblib` or `pickle`.
     - Prepare any encoders or simple mappings (e.g., map
       `exterior_type` string to a numeric code).
   - Define `run(data)`:
     - Accept a JSON-serializable input (dict or list of dicts).
     - Normalize to a pandas DataFrame with the expected columns.
     - Apply any simple preprocessing (e.g., map `exterior_type` to
       integers, one-hot encode `neighborhood_code`).
     - Call `model.predict(...)`.
     - Return predictions as a JSON-serializable object.

2. Input/Output contract:
   - Input: JSON with a top-level list or object of records, where
     each record includes all required feature fields.
   - Output: JSON object such as:
     - `{ "predictions": [123456.78, 234567.89, ...] }`

3. Robustness:
   - Handle missing or malformed inputs with a clear error message.
   - Log basic information (e.g., number of records, feature keys)
     using `print` or `logging` suitable for Azure ML logging.

Constraints:

- Keep the logic simple and easy to explain live.
- Do not introduce heavy dependencies beyond what is in
  `env-infer.yml`.

Important:

- Do NOT print the file contents in chat.
- Write the complete scoring script directly into `src/deploy/score.py`,
  overwriting any existing content.
