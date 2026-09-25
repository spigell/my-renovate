# my-renovate

Central Renovate runner and shared Renovate configuration for the `spigell`
GitHub account.

This repository owns the scheduled Renovate workflow and the shared
`default.json` consumed by the GitHub Action.

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
