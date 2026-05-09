---
name: renovate-guider
description: Troubleshoot this repository's Renovate setup, including custom regex managers, missed dependency updates, Dependency Dashboard states, no-work branches, GitHub Actions workflow permission failures, and Dockerfile or workflow version PRs that Renovate did not create.
---

# Renovate Guider

## Purpose
This skill provides procedural knowledge for the repository's custom Renovate configuration, with emphasis on custom regex managers for Dockerfiles and GitHub Actions workflows.

Use it when diagnosing missed updates, fixing `# renovate:` annotations, interpreting Dependency Dashboard entries, or debugging why Renovate detected a dependency but did not open a pull request.

## Instructions

### 1. `depName` vs. `packageName` Confusion
When creating a `# renovate:` comment for a custom dependency, distinguish between internal grouping and external lookup:

* **`depName` (internal nickname):** The name used to group updates across files. If multiple files share the same `depName`, such as `spigell-codex-binary`, Renovate can update them in a single PR.
* **`packageName` (external source):** The actual registry or repository path Renovate uses to find releases, such as `openai/codex`.
* **Rule:** Ensure custom regex managers capture `depName` and optionally `packageName` as distinct groups. Do not map an internal nickname to the `packageName` capture group.
* **Package rules:** If a package rule targets the internal nickname, use `matchDepNames`. If it targets the external source, use `matchPackageNames`.

### 2. GitHub Actions Context Limitations (`env` inside `with`)
GitHub Actions strictly forbids use of the `env` context, such as `${{ env.VERSION }}`, inside a `uses: ... with:` block.

* Rely on `ARG` defaults declared directly inside the Dockerfile when the Dockerfile owns a static version.
* Do not pass static versions down through workflow `build-args` just to make Renovate see them.
* The workflow should contain a `version:` key only when that key is the version source for the final image tag.

### 3. Docker `build-args` and YAML Literal Blocks
YAML literal blocks, such as `build-args: |`, treat `#` as literal string characters rather than comments. Renovate comments placed there are passed to Docker and can corrupt build arguments or download URLs.

* Never put Renovate comments inside multi-line literal blocks sent to external CLIs.
* Put Renovate annotations on scalar YAML keys or Dockerfile `ARG` lines that the regex manager explicitly matches.

### 4. Regex Brittleness
Custom regex managers fail silently when regexes are too strict.

* End custom manager regexes with `\s*(?:\n|$)` so they tolerate trailing spaces and missing EOF newlines.
* Use non-greedy matchers such as `(.+?)` when matching variable names like `CODEX_BINARY_REF`; greedy matching can fail or over-capture when names contain underscores.
* Verify matches locally with the actual `renovate.json` regex and the target file content before assuming Renovate will see the dependency.

### 5. Versioning Coercion and Prefixes
Strict semver fails on release names with prefixes, such as `rust-v0.130.0`.

* Use `extractVersion` to normalize upstream release names before comparison.
* Pair prefix extraction with `"versioning": "semver-coerced"`.
* Preserve the local value format expected by the repository. For example, if the Dockerfile stores `CODEX_VERSION=v0.130.0` and constructs `rust-${CODEX_VERSION}`, extract `v0.130.0`, not `0.130.0`.
* Do not set `"ignoreUnstable": false` unless prerelease updates such as alpha or preview builds are intentionally desired.

### 6. Invalid Locations for `datasource`
Placing `"datasource": "github-releases"` inside a `packageRules` entry for a custom regex manager can trigger a Renovate configuration validation error.

* For custom regex managers, define the datasource in the regex capture groups, usually through a `# renovate: datasource=...` annotation.
* Keep package rules focused on matching, version extraction, versioning, grouping, labels, and policy decisions.

### 7. Dependency Dashboard and `no-work`
When Renovate detects an update but no PR appears, inspect the Dependency Dashboard first.

* **Detected dependencies:** Confirms the regex manager found the dependency.
* **Other Branches:** Usually means Renovate detected an update but has not opened the PR yet, often due to limits, pending branch state, or dashboard controls.
* **Ignored or Blocked:** Usually means a closed PR or ignored update is suppressing recreation until the dashboard checkbox is selected.
* **`no-work` in logs:** This is a branch processing result, not proof that the dependency lookup failed. Confirm whether the log also shows `newValue`, `newVersion`, and target `packageFile` entries.

Check repository limits before changing regexes:

* `prHourlyLimit`
* `prConcurrentLimit`
* `branchConcurrentLimit`
* Dependency Dashboard approval settings

### 8. GitHub Actions Debugging Workflow
Use the `github-actions-debugger` skill when a Renovate run needs log inspection or manual triggering.

Recommended investigation flow:

1. Inspect the latest Renovate workflow run without triggering a new run.
2. Search logs for `Config validation`, the dependency `depName`, `packageName`, `extractVersion`, `newValue`, `newVersion`, target `packageFile`, `branchName`, `inactiveBranches`, `no-work`, `prNo`, `prHourlyLimit`, `branchConcurrentLimit`, `dependencyDashboard`, and push errors.
3. If log output is truncated, ask for targeted snippets around the exact branch name, such as `renovate/chore/spigell-codex-binary-0.x`.
4. If the tool stores full logs locally, search the saved log files directly with `rg` rather than relying on summarized output.
5. Trigger a new Renovate run only after confirming the repository config or GitHub App permissions changed.

### 9. Known Failure Patterns from This Repository
The Codex Renovate debugging sequence exposed several traps:

* A rule using `matchPackageNames: ["spigell-codex-binary"]` did not target the extracted `packageName` because the custom manager set `packageName=openai/codex`. The correct matcher for the nickname is `matchDepNames`.
* Renovate selected `spigell-codex-binary` `v0.130.0`, but the branch still appeared as `no-work`; this meant update selection was working and the failure was later in branch/PR processing.
* GitHub App tokens need workflow write permission to push Renovate branches that modify `.github/workflows/*`.
* The default hourly PR limit can leave valid updates under Dependency Dashboard `Other Branches`; set `prHourlyLimit` deliberately when fast PR creation is required.
* Codex release asset names must be checked against the actual GitHub release assets. For `rust-v0.130.0`, the Linux binary tarball is `codex-x86_64-unknown-linux-musl.tar.gz`, not `codex-x86_64-unknown-linux-gnu.tar.gz`.
