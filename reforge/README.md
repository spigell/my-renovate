# Reforge definitions for Renovate

The reforge schedules that onboard spigell repositories to this central
Renovate job, test and merge the dependency PRs automerge does not take, and
review the pins in `default.json`, plus the Renovate-specific roles they use.
This directory is the source of truth; the reforge task registry holds the live
copies.

Each schedule runs two steps: `brief` (role `briefer`) writes the worker tasks,
and `debrief` waits until they finish, reports their outcome and may brief
follow-up tasks (also role `briefer`).

- `schedules/renovate-onboarding.yaml`: every 6 hours at minute 40. Its brief
  step outputs onboarding, secret-sync, CI-fix (the standard ci-fix task) and
  tailor tasks; its debrief step reports what they moved forward and may
  output one process task.
- `schedules/renovate-deps.yaml`: every 3 hours, 20 minutes after the Renovate
  job. Its brief step outputs update tasks for majors, grouped by package and
  major across repositories (a pilot repository first, the rest after it
  merged), and for minor/patch PRs with red checks. Each task fixes, tests and
  merges the Renovate PR. Its debrief step reports and may output one rule
  task that pins a package which cannot be upgraded yet, and one standard
  ci-fix task when an update finds a check that already fails on the
  repository's default branch (`needs_operator` with a proven pre-existing
  reason). The brief skips that repository's PRs until the fix lands.

The standard ci-fix task (key `ci-fix:<owner/repo>`, `ci-fixer` then
`reviewer`) is defined once in the `reforge-task-author` skill of
my-reforge-tasks. A schedule enables it in its details instead of copying the
payload. Workers read that skill live from
`/spigell-reforge-ai/reforge/tasks/skills`, so a change there needs no seed
sync, only a merge and a pull of that checkout.
- `schedules/renovate-pins.yaml`: weekly. Reviews one due pin and lifts it,
  raises it, or renews its reason. Lifting a cap hands the new version to
  `renovate-deps` to test. Its debrief step may output one process task.
- `roles/renovate-onboarder.yaml`: sets `renovateEnabled` for one repository in
  spigell/my-github.
- `roles/renovate-applier.yaml`: applies the my-github stack when the only
  change is the `RENOVATE_REPOSITORIES` secret.
- `roles/renovate-pin-reviewer.yaml`: reviews one pin from upstream evidence
  and edits only that rule.
- `roles/renovate-updater.yaml`: the coder of a `renovate-deps` update task.
  It ends as Updated (commit), Nothing to change (`no_changes`, the PR merges
  as it is), or a declared error. `upstream_blocked` carries the reason,
  blocking package and optional upstream URL for the debrief to consider a
  scoped pin. Built-in `needs_operator` carries policy questions and proven
  default-branch failures; `external_unavailable` identifies a down service.
  Errors leave `git status --short` empty: the worker commits any file left
  changed. The debrief reads the role error id and evidence from the task.

Known gaps in `renovate-deps`, which need my-reforge-runner changes:

- A pinned Renovate PR stays open. The worker merges the base branch into the
  Renovate branch before the coder runs, so Renovate treats the branch as
  edited and neither rewrites nor closes it after the pin lands. The brief
  skips such PRs and lists them as pinned and still open. Reset one with its
  rebase/retry checkbox, so Renovate rebuilds the branch under the pin: it
  closes, or becomes the PR for the highest allowed version (a group branch
  such as `renovate/chore/major-typescript` carries no version). Closing it
  by hand makes Renovate ignore that update, which would also hide it after
  the pin is lifted.

Every pin (a packageRule with `allowedVersions` or `enabled: false`) carries
its reason in `description`: `<reason>; source: <URL>; review after:
YYYY-MM-DD`. A pin without that format is due for review.

The generic roles they also use (`briefer`, `debriefer`, `ci-fixer`, `coder`,
`reviewer`) and the `deploy-report` output schema live in my-reforge-tasks.

Seed sync applies these files: merging a change to `main` puts it in the
registry within one sync interval (2 minutes by default), see
my-reforge-tasks `docs/seed-sync.md`. The sync never deletes a row, so a
removed or renamed entry must be deleted by hand with `task-admin registry
role delete --name <id>` or `task-admin schedule delete --name <name>`. A
schedule keeps its paused or running state when it is re-applied.
