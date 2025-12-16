# Infra Prompts (Segment 1)

Workspace prompt files live under `.github/prompts/` and can be run in
VS Code Chat by typing `/infra-bicep-skeleton`, `/infra-bicep-refine`,
etc.

## 01 – Infra Bicep Skeleton

Use this first to generate `src/infrastructure/main.bicep` from scratch.

Prompt file: `.github/prompts/01-infra-bicep-skeleton.prompt.md`

## 02 – Infra Bicep Refine

Use this to tighten and validate `main.bicep` after the initial scaffold.

Prompt file: `.github/prompts/02-infra-bicep-refine.prompt.md`

## 03 – Infra deploy.sh Skeleton

Use this to generate the first version of
`src/infrastructure/deploy.sh`.

Prompt file: `.github/prompts/03-infra-deploy-sh-skeleton.prompt.md`

## 04 – Infra deploy.sh Refine

Use this to harden `deploy.sh` and print deployment outputs.

Prompt file: `.github/prompts/04-infra-deploy-sh-refine.prompt.md`
