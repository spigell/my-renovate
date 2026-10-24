# Reforge definitions for Renovate

The Renovate-specific reforge roles. This directory is the source of truth; the
reforge task registry holds the live copies.

The reforge schedules that used them (`renovate-onboarding`, `renovate-deps`,
`renovate-pins`) and the `renovate` area were removed on 2026-10-20 at the
operator's request; their registry rows were deleted by hand. Renovate itself
keeps running as the central job in this repository.

The reforge area's `deps-steward` entry (spigell/my-reforge-tasks
`docs/area-deps.md`) now runs `renovate-updater` and `renovate-pin-reviewer`
for the reforge repositories: it lands their Renovate PRs that need code
(majors, red minor and patch updates) and reviews their due `renovate.json`
pins.

- `roles/renovate-onboarder.yaml`: sets `renovateEnabled` for one repository in
  spigell/my-github.
- `roles/renovate-applier.yaml`: applies the my-github stack when the only
  change is the `RENOVATE_REPOSITORIES` secret.
- `roles/renovate-pin-reviewer.yaml`: reviews one pin from upstream evidence
  and edits only that rule.
- `roles/renovate-updater.yaml`: the coder of a Renovate update task. It ends
  as Updated (commit), Nothing to change (`no_changes`, the PR merges as it
  is), or a declared error (`upstream_blocked`, `needs_operator`,
  `external_unavailable`).

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
