# Repository Guidelines

## Skills index
- `renovate-guider` (`.agents/skills/renovate-guider/SKILL.md`): Troubleshoot and validate the central Renovate runner in `my-renovate`, including the shared `renovate.json`, custom regex managers, Dependency Dashboard states, and runner permissions.

## Repository scope
- This repository owns the central Renovate GitHub Action workflow for the `spigell` account.
- `renovate.json` is the source of truth for shared Renovate behavior used by the scheduled runner.
- `.github/workflows/renovate.yaml` is the source of truth for the central Renovate execution flow and GitHub App token wiring.
- `reforge/` is the source of truth for the Renovate reforge schedules and their Renovate-specific roles. The reforge task registry holds the live copies.

## Reforge schedules
- Every schedule runs a `brief` step (role `briefer`) that writes the worker tasks, and a `debrief` step (also `briefer`) that waits for them, reports their outcome, and may brief one follow-up task.
- `reforge/schedules/renovate-onboarding.yaml`: runs every 6 hours. It briefs onboarding, secret-sync, CI-fix, and tailor tasks that bring spigell repositories onto the central Renovate job. Its debrief may output one process task.
- `reforge/schedules/renovate-deps.yaml`: runs every 3 hours, 20 minutes after the Renovate job. It fixes, tests, and merges the Renovate PRs that automerge does not take: majors (a pilot repository first, then the rest) and minor or patch PRs with red checks. Its debrief may add one rule task that pins a package that cannot be upgraded yet.
- `reforge/schedules/renovate-pins.yaml`: runs weekly. It reviews one due pin in `default.json` and lifts it, raises it, or renews its reason. When a cap is lifted, `renovate-deps` tests the new version. Its debrief may output one process task.
- `reforge/roles/`: `renovate-onboarder` (sets `renovateEnabled` in spigell/my-github), `renovate-applier` (applies the my-github stack for `RENOVATE_REPOSITORIES` secret-only changes), and `renovate-pin-reviewer` (edits one pin rule from upstream evidence).
- The generic roles (`briefer`, `debriefer`, `ci-fixer`, `coder`, `reviewer`) and the `deploy-report` schema live in my-reforge-tasks, not here.

## Reforge rules
- Every pin (a packageRule with `allowedVersions` or `enabled: false`) must keep its reason in `description` as `<reason>; source: <URL>; review after: YYYY-MM-DD`. A pin that does not follow this format counts as due for review.
- Seed sync applies `reforge/` from `main` within about 2 minutes of a merge; do not upsert by hand. See `reforge/README.md`.
- Seed sync never deletes rows: after removing or renaming a role or schedule, delete the old row by hand with `task-admin`, once no schedule or open task references it.
- Keep a schedule member's `key` stable: the runner finds the previous run's debrief through it.
