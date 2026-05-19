---
name: renovate-guider
description: Troubleshoot and validate the central Renovate runner in my-renovate, including the shared renovate.json, custom regex managers, Dependency Dashboard states, and runner permissions.
---

# Renovate Guider (Central Configuration)

## Purpose
This skill provides procedural knowledge for maintaining, troubleshooting, and locally testing the central Renovate execution flow and shared configuration rules housed in the `my-renovate` repository.

## Instructions

### 1. Core Sources of Truth
* `renovate.json`: Defines the shared behavior and custom regex managers.
* `.github/workflows/renovate.yaml`: Controls the scheduled execution, token generation, and runner environment.

### 2. Custom Regex Managers
The central config implements specific custom regex managers. When troubleshooting missed updates across the organization, verify the target matches these rules:

* **Dockerfiles:** Matches `ARG` variables ending in `_VERSION`, `_GIT_REF`, or `_IMAGE_TAG`.
* **YAML Files:** Matches keys ending in `version`, such as `tool_version` and `cli-version`, under `.github/workflows` and `.github/actions`.
* **Brittleness:** Ensure any modifications to custom manager regexes end with `\s*(?:\n|$)` so they tolerate trailing spaces and missing EOF newlines.

### 3. Validating the Central Config
Always run the validator against the shared config before testing behavior or pushing changes:

`yarn dlx --package renovate renovate-config-validator --strict /spigell-reforge-ai/my-shared-infra/my-renovate/renovate.json`

### 4. Local Dry Runs with Both Configs
Run Renovate in dry-run mode against the target repository while loading both the repository config and the central shared config from absolute paths.

Use:

`LOG_LEVEL=debug yarn dlx --package renovate renovate --platform=local --dry-run=full --print-config=true --repo-cache=reset --local-dir /full/path/to/target-repo --require-config=ignored --config-file /full/path/to/target-repo/renovate.json --extends local>spigell/my-renovate --global-config /spigell-reforge-ai/my-shared-infra/my-renovate/renovate.json`

Notes:
* Replace `/full/path/to/target-repo` with the absolute repository path under test.
* Use full paths for both config files. Do not rely on the shell working directory.
* The repository config remains the repo's own `renovate.json`; the shared config comes from `/spigell-reforge-ai/my-shared-infra/my-renovate/renovate.json`.
* If the repository extends a narrower preset instead of `local>spigell/my-renovate`, keep that repo-local `extends` value and still pass the shared global config path explicitly.

Search the output strictly for `Detected dependencies`, `extractVersion`, `newVersion`, and `packageFiles with updates` to ensure the regex changes correctly parsed the targeted files and the combined config resolved as expected.

### 5. Debugging the Central Runner Workflow
If local validation passes but the hosted pipeline fails, or PRs do not appear:

* **GitHub App Permissions:** Confirm the app token has workflow write permissions if PRs modifying `.github/workflows/*` are failing to push.
* **Rate Limits:** Note that `prHourlyLimit` is set to `0` in this repo. If PRs are missing, check the Dependency Dashboard for blocked or ignored updates and pending branch states.
* **Workflow Logs:** Use the `github-actions-debugger` skill to inspect the latest central run. Search for `Config validation`, `no-work`, `prNo`, `dependencyDashboard`, and push errors.
