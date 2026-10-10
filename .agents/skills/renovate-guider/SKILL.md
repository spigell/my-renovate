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
* `default.json`: Shared preset that skips routine language package patches while preserving app, runtime, and vulnerability fix updates. It keeps account-wide rules, policy rules and existing legacy pins until they are migrated; `policy:` rules are excluded from pin reviews.
* Target repository `renovate.json`: Extends the central preset and holds new pins that apply only to that repository. Keep its `extends` when adding a packageRule. Review pins here and in `default.json`; an account-wide pin in `default.json` requires explicit operator approval.
* `.github/workflows/renovate.yaml`: Controls the scheduled execution, token generation, and runner environment.

### 2. Custom Regex Managers
The central config implements specific custom regex managers. When troubleshooting missed updates across the organization, verify the target matches these rules:

* **Dockerfiles:** Matches `ARG` variables ending in `_VERSION`, `_GIT_REF`, or `_IMAGE_TAG`.
* **YAML Files:** Matches keys ending in `version`, such as `tool_version` and `cli-version`, under `.github/workflows` and `.github/actions`.
* **Brittleness:** Ensure any modifications to custom manager regexes end with `\s*(?:\n|$)` so they tolerate trailing spaces and missing EOF newlines.

### 3. Validating the Central Config
Always run the validator against the shared config before testing behavior or pushing changes:

`yarn dlx --package renovate@43.222.0 renovate-config-validator --strict default.json`

Run the same strict validator on a target repository's `renovate.json` when changing a local pin.

### 4. Local Dry Runs with Target Repository
To test Renovate against a specific target repository (e.g., `/spigell-reforge-ai/my-shared-infra/my-images`) and see its proposed updates, you must navigate into that repository's directory. This ensures Renovate correctly identifies the local context and its `renovate.json` configuration.

#### Steps:
1. **Navigate to the target repository:**
   `cd /spigell-reforge-ai/my-shared-infra/my-images`

2. **Temporarily inline the central config rules:**
   Because `platform=local` does not support fetching remote `extends` (like `github>spigell/my-renovate`), you must temporarily copy the necessary custom rules (managers, datasources) directly into the target repository's `renovate.json` for the duration of the test.

3. **Run Renovate in dry-run mode:**
   `LOG_LEVEL=debug yarn dlx --package renovate renovate --platform=local --dry-run=full --print-config=true`

4. **Restore the `extends` configuration:**
   After a successful local check, remove the temporarily inlined rules and ensure the repository's `renovate.json` includes the central config for hosted execution:
   ```json
   {
     "extends": [
       "github>spigell/my-renovate"
     ]
   }
   ```

#### Notes:
* Replace `/spigell-reforge-ai/my-shared-infra/my-images` with the actual path to your target repository.
* The `--platform=local` flag tells Renovate to operate on the local filesystem.
* `--dry-run=full` shows all proposed changes without applying them.
* `--print-config=true` displays the resolved Renovate configuration for debugging.
* Search the output strictly for `Detected dependencies`, `extractVersion`, `newVersion`, and `packageFiles with updates` to ensure your changes correctly parsed the targeted files and the combined config resolved as expected.

### 5. Debugging the Central Runner Workflow
If local validation passes but the hosted pipeline fails, or PRs do not appear:

* **GitHub App Permissions:** Confirm the app token has workflow write permissions if PRs modifying `.github/workflows/*` are failing to push.
* **Rate Limits:** Note that `prHourlyLimit` is set to `0` in this repo. If PRs are missing, check the Dependency Dashboard for blocked or ignored updates and pending branch states.
* **Workflow Logs:** Scheduled runs log at `warn`, and `delete-renovate-logs.yaml` deletes each run's log when it ends once the repository is public. To debug, dispatch `renovate.yaml` with `log_level: debug` (and `repositories` set to the one repository), then read the log with the `github-actions-debugger` skill while the run is still in progress. Search for `Config validation`, `no-work`, `prNo`, `dependencyDashboard`, and push errors. Never paste a private repository's log content into a public issue or PR.
