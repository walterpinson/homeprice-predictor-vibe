---
name: train-script-scikit
description: Create a scikit-learn training script that runs as an Azure ML job
agent: agent
argument-hint: Optionally specify the model type (e.g., linear vs random forest)
---

You are helping create the TRAINING SCRIPT for the house price demo.

Task:

- Create or fully overwrite `src/ml-pipeline/train.py`.

Assumptions:

- The Azure ML workspace and AmlCompute cluster already exist.
- Data assets will be registered later using MLTable definitions from:
  - `src/data/mltable/train/MLTable`
  - `src/data/mltable/val/MLTable`
- For now, focus on the script that will run inside an Azure ML job.

Requirements for `train.py`:

1. Entry point:
   - Use a standard Python main guard (`if __name__ == "__main__":`).
   - Accept command‑line arguments for:
     - `--train-data` (URI or local path for the training MLTable).
     - `--val-data` (URI or local path for the validation MLTable).
     - `--target-column` (e.g., `price`).

2. Data loading:
   - Use pandas to read the MLTable‑materialized data.
   - Split into features X and target y based on `--target-column`.

3. Model:
   - Use a simple scikit‑learn regression model (e.g., RandomForestRegressor
     or LinearRegression) that trains quickly on ~500 rows.
   - Fit on the training data.

4. Evaluation:
   - Evaluate on validation data with at least:
     - RMSE (root mean squared error).
   - Print metrics to stdout.
   - Optionally, log metrics using `mlflow` or basic logging, but keep it
     simple for the demo.

5. Output:
   - Save the trained model to an `./outputs` directory as `model.pkl`
     using `joblib` or `pickle`.
   - Ensure the script creates `./outputs` if it does not exist.

Constraints:

- Keep dependencies limited to Python stdlib + pandas + scikit-learn +
  joblib/pickle.
- Make the script runnable locally for quick testing, but also suitable
  as the `command` for an Azure ML ScriptJob.

Important:

- Do NOT print the file content in chat.
- Write the complete script directly to `src/ml-pipeline/train.py`,
  overwriting any existing content.
