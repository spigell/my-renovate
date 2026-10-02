# Reforge definitions for Renovate

The reforge autopilots that onboard spigell repositories to this central
Renovate job, test and merge the dependency PRs automerge does not take, and
review the pins in `default.json`, plus the Renovate-specific roles they use.
This directory is the source of truth; the reforge task registry holds the live
copies.

- `schedules/renovate-onboarding.yaml`: the onboarding autopilot, every 6
  hours at minute 40. Its planner outputs onboarding, secret-sync, CI-fix and
  tailor tasks; its feedback step reports what they moved forward and may
  output one process task.
- `schedules/renovate-deps.yaml`: every 3 hours, 20 minutes after the Renovate
  job. Its planner outputs update tasks for majors, grouped by package and
  major across repositories (a pilot repository first, the rest after it
  merged), and for minor/patch PRs with red checks. Each task fixes, tests and
  merges the Renovate PR. Its feedback step reports and may output one rule
  task that pins a package which cannot be upgraded yet.
- `schedules/renovate-pins.yaml`: weekly. Reviews one due pin and lifts it,
  raises it, or renews its reason. Lifting a cap hands the new version to
  `renovate-deps` to test. Its feedback step may output one process task.
- `roles/renovate-onboarder.yaml`: sets `renovateEnabled` for one repository in
  spigell/my-github.
- `roles/renovate-applier.yaml`: applies the my-github stack when the only
  change is the `RENOVATE_REPOSITORIES` secret.
- `roles/renovate-pin-reviewer.yaml`: reviews one pin from upstream evidence
  and edits only that rule.

Every pin (a packageRule with `allowedVersions` or `enabled: false`) carries
its reason in `description`: `<reason>; source: <URL>; review after:
YYYY-MM-DD`. A pin without that format is due for review.

The generic roles they also use (`autopilot-planner`, `autopilot-feedback`,
`ci-fixer`, `coder`, `reviewer`) and the `deploy-report` output schema live in
my-reforge-tasks.

Apply changes from a reforge workbench with `task-admin`, roles first:

```bash
for f in reforge/roles/*.yaml; do task-admin registry role upsert --file "$PWD/$f"; done
for f in reforge/schedules/*.yaml; do task-admin schedule upsert --file "$PWD/$f"; done
```

`--file` paths must be under `/spigell-reforge-ai`, so run this from a checkout
there. Note that a schedule upsert re-enables a paused schedule.
