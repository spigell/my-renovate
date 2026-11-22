# my-renovate

Central Renovate runner and shared Renovate configuration for the `spigell`
GitHub account.

This repository owns the scheduled Renovate workflow and the shared
`default.json` consumed by the GitHub Action.

The shared preset skips routine patch updates for language packages while
keeping minor, major, app, runtime, and vulnerability fix updates.
It labels Dependency Dashboard issues `dependency-dashboard`.

## Validation

Validate config changes with the Renovate version the runner uses
(`renovate-version` in `.github/workflows/renovate.yaml`, the only place it is
pinned):

```sh
npm run validate                    # default.json, renovate.json, presets/*.json
npm run validate -- default.json    # chosen files
```

From another repository, validate its `renovate.json` with the same version:

```sh
curl -fsSL https://raw.githubusercontent.com/spigell/my-renovate/main/scripts/validate-config.sh | bash -s -- renovate.json
```

A newer Renovate can demand config migrations that the runner's version
rejects, so never validate with an unpinned release. When the runner version
is bumped, migrate the config in the same change.

## Run logs

The job scans mostly private repositories, and the run logs of a public
repository are visible to everyone. Scheduled runs therefore log at `warn`,
and `.github/workflows/delete-renovate-logs.yaml` deletes each run's log as
soon as the run ends (it is skipped while the repository is private). To
debug, dispatch the Renovate workflow with `log_level: debug` and, ideally,
`repositories` set to one repository, then read the log while the run is in
progress.

## Shared presets

The preset files under `presets/` are opt-in additions for repositories that
use the corresponding dependency annotations. Add one or both to a
repository's `renovate.json` with `extends`:

```json
{
  "extends": [
    "github>spigell/my-renovate//presets/dockerfile-managers.json",
    "github>spigell/my-renovate//presets/workflow-managers.json"
  ]
}
```

### `dockerfile-managers`

Adds regex managers for `Dockerfile` `ARG` instructions annotated with
`renovate:` metadata. It supports arguments ending in `_VERSION`, `_GIT_REF`,
or `_IMAGE_TAG`, and also supports paired `_GIT_REF`/`_GIT_SHA` arguments for
updating a Git reference and its commit digest together.

### `workflow-managers`

Adds a regex manager for version keys in YAML files under `.github/workflows`
and `.github/actions`. Keys such as `tool_version` and `cli-version` are
supported when the value includes a `renovate:` annotation.
