# Reforge definitions for Renovate

The `renovate` area and the Renovate-specific reforge roles. This directory is
the source of truth; the reforge task registry holds the live copies.

This repository runs no reforge schedules of its own: each area looks after its
own repositories' dependencies. The reforge area's `deps-steward` entry
(spigell/my-reforge-tasks `docs/area-deps.md`) runs `renovate-updater` and
`renovate-pin-reviewer` for the reforge repositories: it lands their Renovate
PRs that need code (majors, red minor and patch updates) and reviews their due
`renovate.json` pins. Renovate itself keeps running as the central job in this
repository.

- `areas/renovate.yaml`: the `renovate` area, scoped to this repository's
  shared config (`default.json`, `presets/`). A dependency steward never adds
  annotations, custom managers or regexes to its own repositories; when its
  work meets a version Renovate misses, it sends this area an idea asking for a
  shared preset. Ideas from other areas wait for the operator's Accept, so the
  operator decides what Renovate tracks; the `idea-refiner` entry (shipped
  disabled) turns accepted ideas into preset tasks on this repository.
- `roles/renovate-pin-reviewer.yaml`: reviews one pin from upstream evidence
  and edits only that rule.
- `roles/renovate-updater.yaml`: the coder of a Renovate update task. It ends
  as Updated (commit), Nothing to change (`no_changes`, the PR merges as it
  is), or a declared error (`upstream_blocked`, `needs_operator`,
  `external_unavailable`).

The `renovate-onboarding`, `renovate-deps` and `renovate-pins` schedules and
the old guest `renovate` area were removed on 2026-10-20 (#69); the area came
back on 2026-10-24 scoped to this repository. The `renovate-onboarder` and
`renovate-applier` roles, used only by the onboarding schedule, were removed
with this change.

New repository-specific pins live in the target repository's `renovate.json`.
Shared `default.json` keeps account-wide rules, policy rules and existing
legacy pins. An account-wide pin needs explicit operator approval. Every pin in
either location (a packageRule with `allowedVersions` or `enabled: false`,
excluding standing rules whose description starts with `policy:`) carries its
reason in `description`: `<reason>; source: <URL>; review after: YYYY-MM-DD`.

Seed sync applies these files: merging a change to `main` puts it in the
registry within one sync interval (2 minutes by default), see
my-reforge-tasks `docs/seed-sync.md`. The sync never deletes a row, so a
removed or renamed entry must be deleted by hand with `task-admin registry
role delete --name <id>` or `task-admin schedule delete --name <name>`.
