# GitHub Actions Check Details

Use these instructions while investigating a submitted PR. Stay read-only:
do not rerun jobs, cancel runs, approve deployments, edit workflows, or change
PR state during evidence collection.

## Identify failed checks and runs

Start with the PR head SHA and list checks:

```bash
gh pr checks <number> --json name,state,link,workflow,startedAt,completedAt,bucket
gh api repos/<owner>/<repo>/commits/<head_sha>/check-runs --paginate
```

Capture each check-run ID, name, workflow, job, status, conclusion, URL,
details URL, and output title/summary/text. Treat `failure`, `timed_out`,
`action_required`, and `startup_failure` as failures. Report `cancelled`,
`skipped`, `neutral`, and pending states separately.

For each failed check run, fetch annotations:

```bash
gh api repos/<owner>/<repo>/check-runs/<check_run_id>
gh api repos/<owner>/<repo>/check-runs/<check_run_id>/annotations --paginate
```

Prefer annotations for compiler, lint, type-check, and test failures. Record
the level, path, line, message, and annotation URL.

## Fetch failed job logs

Find the workflow run and inspect only failed jobs:

```bash
gh run list --commit <head_sha> \
  --json databaseId,displayTitle,event,headSha,status,conclusion,url,workflowName
gh run view <run_id> --json jobs
gh run view <run_id> --log-failed
gh run view <run_id> --job <job_id> --log
```

Extract the failed step and the smallest useful excerpt around the first
error, stack trace, failing test, or nonzero command. Do not paste unrelated
successful output.

For each failure, report the workflow, job, step, GitHub-reported error,
run/check URL, likely cause (explicitly marked as inference when needed), and
proposed fix with a validation command. If logs are unavailable because of
permissions or retention, state that limitation precisely.
