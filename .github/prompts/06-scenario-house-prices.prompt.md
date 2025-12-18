---
name: scenario-house-prices
description: Generate a realistic house price prediction scenario narrative
agent: agent
argument-hint: Optionally specify a city/market for the scenario
---

You are helping create the STORY for a house price prediction demo.

Task:

- Create or overwrite the file `src/data/README.md` with a concise,
  narrative description of the scenario.

Requirements for the scenario:

- It should describe a small property investment or real‑estate analytics
  firm that wants to predict residential sale prices in a specific market
  (you may choose a plausible city or region).
- Explain in plain language:
  - Why predicting sale price matters for this firm.
  - What kinds of features they have collected (e.g., square footage,
    bedrooms, bathrooms, year built, neighborhood code, garage spaces,
    condition score).
  - How more accurate predictions would help them (e.g., better offers,
    portfolio strategy, risk management).
- The tone should be realistic and business‑oriented, not like a toy
  tutorial example.
- Keep it to 3–5 short paragraphs; this file will be used as both
  documentation and context during the talk.

Important:

- Do NOT print the file contents in chat.
- Write directly to `src/data/README.md`, overwriting any existing content.
