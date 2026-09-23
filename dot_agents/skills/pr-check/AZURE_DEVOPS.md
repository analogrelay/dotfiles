# Azure DevOps Pipeline Results

Use these steps when a PR check links to Azure DevOps or reports an Azure
Pipelines status. Stay read-only: do not rerun builds, cancel runs, queue new
runs, approve deployments, or modify pipeline definitions while gathering
evidence.

## Identify Azure DevOps checks from GitHub

1. Inspect `gh pr checks` output and check-run details for checks whose name,
   app, `details_url`, or `target_url` references Azure Pipelines or
   `dev.azure.com`.
2. Capture the GitHub status context or check name, state, conclusion,
   `target_url` or `details_url`, and PR head SHA.
3. Parse the Azure DevOps organization, project, build ID, run ID, or timeline
   record IDs from the URL when present. Common URLs include:
   - `https://dev.azure.com/{org}/{project}/_build/results?buildId={build_id}`
   - `https://dev.azure.com/{org}/{project}/_build/results?buildId={build_id}&view=logs`
   - `https://dev.azure.com/{org}/{project}/_build/results?buildId={build_id}&view=ms.vss-test-web.build-test-results-tab`
4. If the Azure URL is missing or opaque, inspect the GitHub commit statuses:

   ```bash
   gh api repos/{owner}/{repo}/commits/{head_sha}/status
   gh api repos/{owner}/{repo}/commits/{head_sha}/check-runs --paginate
   ```

## Prefer the Azure CLI when available

If `az` with the Azure DevOps extension is installed and already
authenticated, use it to collect build details:

```bash
az pipelines runs show \
  --organization "https://dev.azure.com/{org}" \
  --project "{project}" \
  --id {build_id}

az pipelines runs artifact list \
  --organization "https://dev.azure.com/{org}" \
  --project "{project}" \
  --run-id {build_id}
```

If the Azure DevOps extension is missing, do not install it just for
inspection. Use the REST API instructions below instead.

## Fetch build, timeline, and log details with REST

Use Azure DevOps REST endpoints when credentials are already available in the
environment or the current session is authenticated. Do not ask the user for a
personal access token unless they explicitly choose to provide one.

```bash
curl -fsS \
  "https://dev.azure.com/{org}/{project}/_apis/build/builds/{build_id}?api-version=7.1"

curl -fsS \
  "https://dev.azure.com/{org}/{project}/_apis/build/builds/{build_id}/timeline?api-version=7.1"
```

From the timeline, identify records with `result` values such as `failed`,
`canceled`, or `succeededWithIssues`. Capture the stage, phase, job, task,
record ID, log ID, start/finish times, issue messages, and direct log URL if
present.

Fetch logs for failed timeline records:

```bash
curl -fsS \
  "https://dev.azure.com/{org}/{project}/_apis/build/builds/{build_id}/logs/{log_id}?api-version=7.1"
```

When a log is large, inspect the smallest relevant excerpt around the first
`##[error]`, failed test, compiler error, nonzero exit, or stack trace.

## Fetch test failure details

If the failure appears to be test-related, retrieve test runs and failed
results:

```bash
curl -fsS \
  "https://dev.azure.com/{org}/{project}/_apis/test/runs?buildIds={build_id}&api-version=7.1"

curl -fsS \
  "https://dev.azure.com/{org}/{project}/_apis/test/Runs/{test_run_id}/results?outcomes=Failed&api-version=7.1"
```

Record failed test names, owning job, error messages, stack traces, attachments
or result URLs, and whether failures look deterministic or infrastructure
related.

## Preserve evidence in the plan

For every failed Azure DevOps pipeline check, include:

1. Pipeline/build name and build ID.
2. Stage, job, and task that failed.
3. Azure-reported error, failed test, or timeline issue.
4. A link to the Azure DevOps run or log.
5. The likely cause, clearly marked as inference when it is not directly
   stated by Azure DevOps.
6. The proposed fix and validation command.

If Azure DevOps details are inaccessible because authentication, permissions,
retention, or external-provider limits prevent access, state exactly what was
available from GitHub and what additional access would be needed.
