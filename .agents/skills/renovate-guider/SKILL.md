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

### 4. Local Dry Runs for the Central Config
Run Renovate in dry-run mode against a minimal test case locally to verify the regex logic without interacting with GitHub APIs:

`LOG_LEVEL=debug yarn dlx --package renovate renovate --platform=local --dry-run=full --print-config=true`

Search the output strictly for `Detected dependencies`, `extractVersion`, and `newVersion` to ensure the regex changes correctly parsed the targeted files.

### 5. Debugging the Central Runner Workflow
If local validation passes but the hosted pipeline fails, or PRs do not appear:

* **GitHub App Permissions:** Confirm the app token has workflow write permissions if PRs modifying `.github/workflows/*` are failing to push.
* **Rate Limits:** Note that `prHourlyLimit` is set to `0` in this repo. If PRs are missing, check the Dependency Dashboard for blocked or ignored updates and pending branch states.
* **Workflow Logs:** Use the `github-actions-debugger` skill to inspect the latest central run. Search for `Config validation`, `no-work`, `prNo`, `dependencyDashboard`, and push errors.
