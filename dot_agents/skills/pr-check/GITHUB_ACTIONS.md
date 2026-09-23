# GitHub Actions Check Results

Use these steps when a PR check is backed by GitHub Actions. Stay read-only:
do not rerun jobs, cancel runs, approve deployments, or edit workflow files
while gathering evidence.

## Identify failed Actions runs

1. Start from the PR head SHA gathered by the main skill.
2. List checks and capture the check-run database ID, workflow name, job name,
   status, conclusion, URL, and `detailsUrl`:

   ```bash
   gh pr checks --json name,state,link,workflow,startedAt,completedAt,bucket
   ```

3. Query check runs directly when `gh pr checks` omits IDs or annotations:

   ```bash
   gh api repos/{owner}/{repo}/commits/{head_sha}/check-runs \
     --paginate \
     --jq '.check_runs[] | {id, name, status, conclusion, html_url, details_url, output}'
   ```

4. Treat `failure`, `timed_out`, `action_required`, and `startup_failure` as
   failures to investigate. Report `cancelled`, `skipped`, and `neutral`
   separately unless the PR requires them to pass.

## Fetch annotations and check output

For each failed check run:

```bash
gh api repos/{owner}/{repo}/check-runs/{check_run_id}
gh api repos/{owner}/{repo}/check-runs/{check_run_id}/annotations --paginate
```

Record:

- Check name and workflow name.
- Conclusion and URL.
- `output.title`, `output.summary`, and `output.text`.
- Annotation level, path, start/end line, title, message, raw details, and URL.

Prefer annotations for compiler, lint, type-check, and test failures because
they usually point to the exact file and line that must be addressed.

## Fetch failed job logs

When a check run belongs to a workflow run, extract the run ID from the check
run, details URL, or `gh run list` filtered by the head SHA:

```bash
gh run list --commit {head_sha} --json databaseId,displayTitle,event,headSha,status,conclusion,url,workflowName
gh run view {run_id}
gh run view {run_id} --log-failed
```

If `--log-failed` is incomplete, fetch job metadata and inspect only failed
jobs:

```bash
gh run view {run_id} --json jobs
gh run view {run_id} --job {job_id} --log
```

Extract the smallest useful failure excerpt: failed step name, command output
around the first error, stack trace, file paths, test names, and artifact or
report links. Avoid pasting unrelated successful log output.

## Preserve evidence in the plan

For every failed GitHub Actions check, include:

1. Workflow and job name.
2. Failed step, if known.
3. GitHub-reported error or annotation.
4. A link to the check, job, or run.
5. The likely cause, clearly marked as inference when it is not directly
   stated by GitHub.
6. The proposed fix and validation command.

If logs or annotations are unavailable because of permissions or retention,
state that explicitly and base the plan only on accessible evidence.
