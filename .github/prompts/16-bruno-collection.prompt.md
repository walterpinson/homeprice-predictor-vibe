---
name: bruno-collection-setup
description: Create a Bruno collection for the house price API
agent: agent
argument-hint: Optionally specify a collection name
---

You are helping set up a Bruno collection for calling the Azure ML
managed online endpoint.

Tasks:

- Create or overwrite the following under the repo root:
  - `bruno/house-price-api/bruno.json`
  - `bruno/house-price-api/environments/demo.bru.sample`

Requirements:

1. `bruno.json`:
   - Define a minimal collection metadata file with:
     - A human-friendly name (e.g., "House Price API").
     - Any required fields for Bruno to recognize the folder as a collection.
   - Assume this collection will contain:
     - An environment file for base URL and key.
     - Several POST requests to the endpoint.

2. `demo.bru.sample`:
   - Define an environment file with placeholders for:
     - `baseUrl` (e.g., `{{BASE_URL_HERE}}`).
     - `apiKey` (e.g., `{{API_KEY_HERE}}`).
   - Include comments or description indicating that users should:
     - Copy this file to `demo.bru`.
     - Fill in the real base URL and API key or token.

Important:

- Do NOT print any file contents in chat.
- Write directly to:
  - `bruno/house-price-api/bruno.json`
  - `bruno/house-price-api/environments/demo.bru.sample`
  overwriting any existing content.
