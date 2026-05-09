# Repository Guidelines

## Skills index
- `renovate-guider` (`.agents/skills/renovate-guider/SKILL.md`): Troubleshoot this repository's Renovate setup, including custom regex managers, missed dependency updates, Dependency Dashboard states, no-work branches, GitHub Actions workflow permission failures, and Dockerfile or workflow version PRs that Renovate did not create.

## Repository scope
- This repository owns the central Renovate GitHub Action workflow for the `spigell` account.
- `renovate.json` is the source of truth for shared Renovate behavior used by the scheduled runner.
- `.github/workflows/renovate.yaml` is the source of truth for the central Renovate execution flow and GitHub App token wiring.
