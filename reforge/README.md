# Reforge definitions for Renovate

The reforge autopilot that onboards spigell repositories to this central
Renovate job and moves each "Configure Renovate" pull request to merge, and the
Renovate-specific roles it uses. This directory is the source of truth; the
reforge task registry holds the live copies.

- `schedules/renovate-hourly.yaml`: the hourly autopilot. Its planner outputs
  onboarding, secret-sync, CI-fix and tailor tasks; its feedback step reports
  what they moved forward.
- `roles/renovate-onboarder.yaml`: sets `renovateEnabled` for one repository in
  spigell/my-github.
- `roles/renovate-applier.yaml`: applies the my-github stack when the only
  change is the `RENOVATE_REPOSITORIES` secret.

The generic roles it also uses (`autopilot-planner`, `autopilot-feedback`,
`ci-fixer`, `coder`, `reviewer`) and the `deploy-report` output schema live in
my-reforge-tasks.

Apply changes from a reforge workbench with `task-admin`, roles first:

```bash
for f in reforge/roles/*.yaml; do task-admin registry role upsert --file "$PWD/$f"; done
task-admin schedule upsert --file "$PWD/reforge/schedules/renovate-hourly.yaml"
```

`--file` paths must be under `/spigell-reforge-ai`, so run this from a checkout
there. Note that a schedule upsert re-enables a paused schedule.
