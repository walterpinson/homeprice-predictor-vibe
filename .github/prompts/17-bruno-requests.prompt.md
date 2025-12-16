---
name: bruno-requests
description: Create Bruno request files for the house price endpoint
agent: agent
argument-hint: Optionally specify request names or variations
---

You are helping create Bruno request files to call the managed online
endpoint for house price prediction.

Tasks:

- Under `bruno/house-price-api/requests/`, create or overwrite:
  - `predict-basic.bru`
  - `predict-large-house.bru`
  - `predict-fixer-upper.bru`

Requirements for each `.bru` file:

- Target:
  - Use method `POST`.
  - Use URL based on the selected environment's `baseUrl`, appending
    the scoring path (for example `/score`), as is typical for Azure ML
    managed online endpoints.
- Headers:
  - `Content-Type: application/json`
  - `Authorization` header that references the environment's `apiKey`
    (or similar variable), not a hard-coded secret.

- Body:
  - JSON body with a structure compatible with `score.py`, e.g.:

    ```
    {
      "data": [
        {
          "sqft": 1800,
          "bedrooms": 3,
          "bathrooms": 2.0,
          "year_built": 1998,
          "neighborhood_code": "N3",
          "garage_spaces": 2,
          "condition_score": 7,
          "exterior_type": "siding"
        }
      ]
    }
    ```

  - Vary the feature values across the three requests:
    - `predict-basic.bru`: a mid-range, typical house.
    - `predict-large-house.bru`: larger, newer, nicer neighborhood.
    - `predict-fixer-upper.bru`: smaller, older, lower condition score.

Important:

- Do NOT print the `.bru` file contents in chat.
- Write the request definitions directly into:
  - `bruno/house-price-api/requests/predict-basic.bru`
  - `bruno/house-price-api/requests/predict-large-house.bru`
  - `bruno/house-price-api/requests/predict-fixer-upper.bru`
  overwriting any existing content.
