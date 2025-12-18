# From Model to Endpoint

- We now have a registered house‑price model.
- Next step: turn it into a real, callable API.
- Azure ML managed online endpoints handle:
  - Hosting.
  - Scaling.
  - Authentication.
  - Logging.

> This is where the ML model becomes a product surface.

---

# The Role of score.py

- `score.py` is the entry point for inference:
  - `init()` runs once per deployment replica:
    - Load the registered model from `AZUREML_MODEL_DIR`.
  - `run(data)` runs per request:
    - Parse JSON payload.
    - Run `model.predict(...)`.
    - Return predictions as JSON.

> Simple, predictable Python that bridges HTTP requests to your model.

---

# Inference Environment

- Separate environment from training:
  - `env-infer.yml` for lightweight, fast startup.
- Includes:
  - Python, numpy, pandas, scikit‑learn.
  - Azure ML logging/telemetry dependencies if needed.
- Referenced by the online deployment as its runtime.

> The environment defines *how* the model code runs in the cloud.

---

# Creating the Managed Online Endpoint

- Use Azure ML Python SDK v2 to:
  - Define an endpoint (name, auth mode).
  - Define a deployment:
    - Registered model.
    - `score.py` + code folder.
    - Inference environment.
    - Instance type and count.
- Point 100% of traffic to the new deployment.

```bash
cd src/ml-pipeline

./deploy_model_endpoint.sh \
  --model-name house-pricing-01 \
  --model-version 1 \
  --endpoint-name house-price-ep
```

> A few lines of SDK code wire model, code, and environment together.

---

# Testing with Bruno

- Use Bruno as a Git‑friendly API client:
  - Environment variables for:
    - `base-url` (scoring URI).
    - `api-key` or bearer token.
  - Requests that:
    - POST a JSON body with house features.
    - Display the predicted price from the response.
- This becomes our live demo:
  - Change inputs, see predictions in real time.

> From vibe to endpoint: an ML API you can hit from any client.

---

# Troubleshooting: Rebuilding the Environment

- If the deployment fails due to missing packages:
  - Update `env-infer.yml` with required dependencies.
  - Force a rebuild with a new environment version.
- Optional parameters for environment management:
  - `--env-version <version>`: Specify version number (e.g., "2", "3").
  - `--force-env-rebuild`: Force creation of new environment.

```bash
cd src/ml-pipeline

./deploy_model_endpoint.sh \
  --model-name house-pricing-01 \
  --model-version 1 \
  --endpoint-name house-price-ep \
  --env-version 2 \
  --force-env-rebuild
```

> Environment versioning ensures clean rebuilds without orphaned dependencies.
