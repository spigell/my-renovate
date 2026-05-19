# Repository Guidelines

## Skills index
- `renovate-guider` (`.agents/skills/renovate-guider/SKILL.md`): Troubleshoot and validate the central Renovate runner in `my-renovate`, including the shared `renovate.json`, custom regex managers, Dependency Dashboard states, and runner permissions.

## Repository scope
- This repository owns the central Renovate GitHub Action workflow for the `spigell` account.
- `renovate.json` is the source of truth for shared Renovate behavior used by the scheduled runner.
- `.github/workflows/renovate.yaml` is the source of truth for the central Renovate execution flow and GitHub App token wiring.
