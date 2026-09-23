# Azure DevOps Pipeline Details

Use these instructions while investigating a submitted PR. Stay read-only:
do not rerun builds, queue runs, cancel runs, approve deployments, or modify
pipeline definitions.

## Identify Azure checks

Inspect `gh pr checks` and check-run details for `dev.azure.com`, Azure
Pipelines, or an Azure target URL. Capture the status context, check name,
state, conclusion, target/details URL, PR head SHA, organization, project, and
build ID.

Common URLs are:

```text
https://dev.azure.com/<org>/<project>/_build/results?buildId=<build_id>
https://dev.azure.com/<org>/<project>/_build/results?buildId=<build_id>&view=logs
```

If the check does not expose enough information, inspect commit statuses:

```bash
gh api repos/<owner>/<repo>/commits/<head_sha>/status
gh api repos/<owner>/<repo>/commits/<head_sha>/check-runs --paginate
```

## Fetch build and timeline evidence

Use `az` only if it is already installed and authenticated. Do not install a
new extension solely for this investigation:

```bash
az pipelines runs show \
  --organization https://dev.azure.com/<org> \
  --project <project> \
  --id <build_id>
az pipelines runs artifact list \
  --organization https://dev.azure.com/<org> \
  --project <project> \
  --run-id <build_id>
```

Otherwise use the REST API with credentials already available in the session:

```bash
curl -fsS "https://dev.azure.com/<org>/<project>/_apis/build/builds/<build_id>?api-version=7.1"
curl -fsS "https://dev.azure.com/<org>/<project>/_apis/build/builds/<build_id>/timeline?api-version=7.1"
```

From the timeline, identify failed or cancelled records and capture the stage,
job, task, record ID, log ID, issue messages, timestamps, and direct URLs.
Fetch only logs for failed records:

```bash
curl -fsS "https://dev.azure.com/<org>/<project>/_apis/build/builds/<build_id>/logs/<log_id>?api-version=7.1"
```

For test failures, retrieve failed results:

```bash
curl -fsS "https://dev.azure.com/<org>/<project>/_apis/test/runs?buildIds=<build_id>&api-version=7.1"
curl -fsS "https://dev.azure.com/<org>/<project>/_apis/test/Runs/<test_run_id>/results?outcomes=Failed&api-version=7.1"
```

Report the pipeline/build, stage, job, task, Azure-reported error or failed
test, run/log URL, inferred cause (clearly labeled), proposed fix, and
validation command. If authentication, permissions, retention, or provider
limits prevent access, state exactly what was available and what access would
be needed; never ask the user to paste a personal access token.
