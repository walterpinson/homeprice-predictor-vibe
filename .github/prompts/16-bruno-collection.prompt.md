---
name: bruno-collection-setup
description: Create a Bruno collection for the house price API
agent: agent
argument-hint: Optionally specify a collection name
---

You are helping set up a Bruno collection for calling the Azure ML
managed online endpoint.

Tasks:

- Create or overwrite the following:
  - `bruno/house-price-api/bruno.json`
  - `bruno/house-price-api/environments/demo.bru.sample`

Requirements:

1. `bruno.json`:
   - Define a minimal collection metadata file with:
     - A human-friendly name (e.g., "House Price API").
     - Any required fields for Bruno to recognize the folder as a collection.
   - Assume this collection will contain:
     - An environment file for base URL and key.
     - Several POST requests to the endpoint in the collection root.

2. `demo.bru.sample`:
   - Define an environment file with placeholders for:
     - `baseUrl` (e.g., `{{BASE_URL_HERE}}`).
     - `apiKey` (e.g., `{{API_KEY_HERE}}`).
   - IMPORTANT: Do NOT include comments in the file. Bruno will not
     recognize the environment if comments are present.
   - Instead, name the file with `.sample` extension and document in
     the README or other docs that users should:
     - Copy this file to `demo.bru` in the same directory.
     - Replace placeholder values with actual endpoint URL and key.
     - The baseUrl should be the full scoring URI without `/score` path.

Important:

- Do NOT print any file contents in chat.
- Do NOT include comments in the `.bru.sample` file as they prevent
  Bruno from recognizing the environment.
- Write directly to:
  - `bruno/house-price-api/bruno.json`
  - `bruno/house-price-api/environments/demo.bru.sample`
  overwriting any existing content.
