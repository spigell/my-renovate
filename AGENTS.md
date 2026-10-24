# Repository Guidelines

## Skills index
- `renovate-guider` (`.agents/skills/renovate-guider/SKILL.md`): Troubleshoot and validate the central Renovate runner in `my-renovate`, including the shared `renovate.json`, custom regex managers, Dependency Dashboard states, and runner permissions.

## Repository scope
- This repository owns the central Renovate GitHub Action workflow for the `spigell` account.
- `renovate.json` is the source of truth for shared Renovate behavior used by the scheduled runner.
- `.github/workflows/renovate.yaml` is the source of truth for the central Renovate execution flow and GitHub App token wiring.
- Run logs are written for a public repository: the job scans mostly private repositories, so scheduled runs log at `warn` and `.github/workflows/delete-renovate-logs.yaml` deletes each run's log when it ends (skipped while the repository is private). Do not raise the scheduled `LOG_LEVEL`; dispatch a run with `log_level: debug` to debug.
- `reforge/` is the source of truth for the `renovate` area and the Renovate-specific reforge roles. The reforge task registry holds the live copies.

## Reforge area and roles
- This repository runs no reforge schedules of its own. Each area looks after its own repositories' dependencies (the reforge area's `deps-steward` entry, my-reforge-tasks `docs/area-deps.md`) and runs the roles below.
- `reforge/areas/renovate.yaml`: the `renovate` area, scoped to this repository's shared config (`default.json`, `presets/`). Its `idea-refiner` entry turns accepted ideas into shared preset tasks. A dependency steward asks it for a preset when its work meets a version Renovate misses; it never adds annotations, custom managers or regexes to its own repositories. Ideas from other areas wait for the operator's Accept.
- `reforge/roles/`: `renovate-pin-reviewer` (edits one pin rule from upstream evidence) and `renovate-updater` (the coder of a Renovate update task: it ends as Updated, Nothing to change, or a declared error such as `upstream_blocked`).
- The generic roles (`idea-refiner`, `coder`, `reviewer`) live in my-reforge-tasks, not here.

## Reforge rules
- The shared preset skips routine patch updates for language packages; app and runtime patches, and security fixes, remain enabled. Rules whose `description` starts with `policy:` are standing policy, not pins.
- New repository-specific pins live in the target repository's `renovate.json`. Shared `default.json` keeps account-wide rules, policy rules and existing legacy pins until they are migrated. An account-wide pin requires explicit operator approval.
- Every pin in either location (a packageRule with `allowedVersions` or `enabled: false`, excluding `policy:` rules) must keep its reason in `description` as `<reason>; source: <URL>; review after: YYYY-MM-DD`. A pin that does not follow this format counts as due for review.
- Seed sync applies `reforge/` from `main` within about 2 minutes of a merge; do not upsert by hand. See `reforge/README.md`.
- Seed sync never deletes rows: after removing or renaming a role, area or entry, delete the old row by hand with `task-admin`, once no schedule or open task references it.
