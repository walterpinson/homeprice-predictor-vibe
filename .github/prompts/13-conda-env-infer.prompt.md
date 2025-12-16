---
name: conda-env-infer
description: Create a lean Conda environment file for online inference
agent: agent
argument-hint: Optionally specify Python or scikit-learn versions
---

You are helping define the Conda environment for ONLINE INFERENCE for
the house price demo.

Task:

- Create or fully overwrite `src/deploy/env-infer.yml`.

Goals:

- The environment should be suitable for:
  - Azure ML managed online endpoints running `score.py`.
- It can be similar to the training environment but should be as lean
  as reasonably possible.

Requirements for `env-infer.yml`:

- Use a standard Conda YAML structure with:
  - A `name` (e.g., `vibe-ml-infer`).
  - Channels including at least `conda-forge` (and `defaults` if needed).
  - `dependencies` that include:
    - Python 3.10 or 3.11.
    - `numpy`
    - `pandas`
    - `scikit-learn`
    - `pip`
    - Under `pip:`:
      - Any minimal Azure ML logging or utilities needed for
        managed online endpoints (keep this light).

Constraints:

- Keep the environment small to minimize cold start time.
- Avoid heavy or unused packages.

Important:

- Do NOT print the file contents in chat.
- Write the complete YAML directly into `src/deploy/env-infer.yml`,
  overwriting any existing content.
