# my-renovate

Central Renovate runner and shared Renovate configuration for the `spigell`
GitHub account.

This repository owns the scheduled Renovate workflow and the shared
`renovate.json` consumed by the GitHub Action.

Shared preset fragments live under `presets/`. The root `renovate.json`
extends those files for reusable custom manager and version-pinning behavior.
