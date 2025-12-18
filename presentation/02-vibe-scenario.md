# Vibing the Scenario

- We’ve got infrastructure; now we need a story.
- Our goal: a realistic house price prediction problem.
- We will **vibe** the scenario and let GenAI turn intent into context.

> Start from a vibe (“help a small investor predict prices”), not a formal spec.

---

# From Vibe to Business Problem

- Use Copilot to draft a real‑world narrative:
  - Who needs price predictions and why.
  - What data they’ve collected.
  - How better predictions change decisions.
- Capture this in `src/data/README.md` as living documentation.

> The scenario is our north star; the data and model follow from it.

---

# Generating Synthetic Data

- Turn the scenario into tabular data we can train on:
  - Features: sqft, beds, baths, year built, neighborhood, garage, condition.
  - Target: sale price with realistic noise.
- Create **three** datasets from vibes:
  - `train.csv` (~350 rows).
  - `val.csv` (~75 rows).
  - `test.csv` (~75 rows).

> Enough data to feel real, small enough to train live in seconds.

---

# Train / Val / Test – Why Three?

- Train set:
  - Teaches the model the patterns in our synthetic market.
- Validation set:
  - Helps tune and sanity‑check during development.
- Test set:
  - Held back to approximate “unseen” future sales.

> Even in a demo, we respect the basic ML discipline.

---

# Preparing Data for Azure ML

- Use MLTable to describe our CSVs as data assets:
  - One MLTable per split: train, val, test.
  - Simple, file‑based definition; no custom code needed.
- Benefits:
  - Azure ML can read, track, and version our data consistently.
  - Training scripts stay focused on modeling, not file plumbing.

> Vibes → scenario → data → ML‑ready assets. Now we can start training.
