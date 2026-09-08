---
name: pr-check
description: 'Report GitHub pull request check status, annotations, likely causes, and proposed solutions without running tests or modifying code. Use when the user asks to inspect, diagnose, or summarize PR checks or build failures.'
user-invocable: true
disable-model-invocation: false
---

# Check Pull Request Status

Gather deterministic GitHub API data first, then perform a read-only diagnosis.
This skill reports findings only. Do not modify files, run tests, reproduce
failures, rerun jobs, or otherwise change local or remote state.

## Select the pull request

Identify an explicit pull request in the user's prompt. Accepted selectors
include a PR number, PR URL, branch name, or `OWNER/REPO#NUMBER`.

- If the user specified a PR, pass that selector as the script's single
  argument.
- If the user did not specify a PR, pass no argument. The script deliberately
  delegates selection to `gh pr view` in the current working directory.
- Do not guess a PR number from unrelated numbers in the prompt.

## Gather check data

Run exactly one collector appropriate for the current platform:

```bash
~/.agents/skills/pr-check/scripts/pr-check.sh [PR_SELECTOR]
```

```powershell
& "$HOME/.agents/skills/pr-check/scripts/pr-check.ps1" [PR_SELECTOR]
```

The collector emits one JSON document containing:

- `pullRequest`: repository, number, URL, title, branches, and head SHA.
- `summary`: counts for all, passed, running, and failed checks.
- `checks`: every check run and legacy commit status, including its normalized
  `category` (`passed`, `running`, or `failed`) and original GitHub state.
- `annotations`: compiler, lint, test, and other annotations reported by check
  runs, including file locations, messages, raw details, and URLs.

Treat collector failures as blocking. Report the command error instead of
substituting instructions, scraping web pages, or improvising other API calls.

## Diagnose read-only

1. Read the JSON and group checks by `category`.
2. Review every annotation, preserving its check name, level, path, line,
   title, and message.
3. Inspect relevant repository code and configuration using read-only tools.
   Account for the PR head branch shown by the collector and avoid claiming
   local files match that head unless they actually do.
4. Infer likely causes only when supported by the annotations and inspected
   code. Clearly label uncertainty.
5. Do not execute tests, builds, linters, formatters, package installation,
   generated-code commands, or reproduction commands.
6. Do not edit files, commit, push, rerun checks, or post to GitHub.

## Report

Present:

1. PR identity and overall counts.
2. Checks that passed.
3. Checks still running.
4. Checks that failed.
5. Specific reported errors, grouped by check and source location.
6. Likely cause for each diagnosable error, or state that deeper reproduction
   is required.
7. Proposed solutions only where the available evidence supports one.

Distinguish GitHub-reported facts from diagnostic inference. Keep duplicate
annotations only when their check name or reported location differs.
