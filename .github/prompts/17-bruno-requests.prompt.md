---
name: bruno-requests
description: Create Bruno request files for the house price endpoint
agent: agent
argument-hint: Optionally specify request names or variations
---

You are helping create Bruno request files to call the managed online
endpoint for house price prediction.

Tasks:

- Under `bruno/house-price-api/`, create or overwrite:
  - `predict-basic.bru`
  - `predict-large-house.bru`
  - `predict-fixer-upper.bru`

Note: Place request files directly in the collection root folder, NOT in
a `requests/` subfolder.

Requirements for each `.bru` file:

- Target:
  - Use method `POST`.
  - Use URL based on the selected environment's `baseUrl`, appending
    the scoring path (for example `/score`), as is typical for Azure ML
    managed online endpoints.

- Authentication:
  - Set `auth: bearer` in the `post` section.
  - Create a separate `auth:bearer` section with:
    - `token: {{apiKey}}`
  - Do NOT use an `Authorization` header in the `headers` section.

- Headers:
  - `Content-Type: application/json`
  - No Authorization header (handled via auth:bearer section).

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
  - `bruno/house-price-api/predict-basic.bru`
  - `bruno/house-price-api/predict-large-house.bru`
  - `bruno/house-price-api/predict-fixer-upper.bru`
  overwriting any existing content.
