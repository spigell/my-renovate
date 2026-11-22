#!/usr/bin/env bash
# Validate Renovate config files with the Renovate version the central runner
# uses: `renovate-version` in .github/workflows/renovate.yaml of my-renovate.
# That workflow pin is the only place the version is set, so the validator
# moves with the runner and never runs an unpinned or self-chosen release.
#
# In my-renovate (default files: default.json, renovate.json, presets/*.json):
#   npm run validate [-- <file>...]
# In any other repository:
#   curl -fsSL https://raw.githubusercontent.com/spigell/my-renovate/main/scripts/validate-config.sh | bash -s -- renovate.json
#
# Exit codes: 0 valid, 1 the validator found errors, 2 the runner version
# could not be read.
set -euo pipefail

workflow_url=https://raw.githubusercontent.com/spigell/my-renovate/main/.github/workflows/renovate.yaml

src=${BASH_SOURCE[0]:-}
local_workflow=
if [[ -n "$src" && -f "$src" ]]; then
  local_workflow="$(cd "$(dirname "$src")/.." && pwd)/.github/workflows/renovate.yaml"
fi

if [[ -n "$local_workflow" && -f "$local_workflow" ]]; then
  workflow=$(cat "$local_workflow")
else
  workflow=$(curl -fsSL "$workflow_url") || {
    echo "validate-config: cannot download $workflow_url" >&2
    exit 2
  }
fi

version=$(sed -n 's/^[[:space:]]*renovate-version:[[:space:]]*\([0-9][0-9.]*\).*/\1/p' <<<"$workflow" | head -n 1)
if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "validate-config: cannot read renovate-version from the Renovate workflow (got '${version}')" >&2
  exit 2
fi

if [[ $# -eq 0 ]]; then
  set -- default.json renovate.json presets/*.json
fi

echo "validate-config: renovate@${version}" >&2
exec npm exec --yes --package "renovate@${version}" -- renovate-config-validator --strict "$@"
