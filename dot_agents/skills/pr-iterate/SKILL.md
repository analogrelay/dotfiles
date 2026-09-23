---
name: pr-iterate
description: Inspect submitted pull request feedback and failing checks, then present a user-approved plan to resolve them without writing review replies.
user-invocable: true
disable-model-invocation: false
---

# Iterate on a Pull Request

Use this skill after a pull request has been submitted and the user wants to
address review feedback, failing checks, or both. This skill is an
investigation-and-planning step first: do not modify code or PR state until the
user reviews and approves the remediation plan.

## Identify the PR and target repository

1. Inspect the current branch and remotes:

   ```bash
   git branch --show-current
   git remote -v
   ```

2. If an `upstream` remote exists, treat it as the PR target repository.
   Otherwise use `origin` as the target. In a fork workflow, `origin` is
   normally the head repository and `upstream` is the base repository; do not
   assume the reverse.
3. Use `gh` to identify the PR for the current branch:

   ```bash
   gh pr view --json number,url,title,state,headRefName,headRepository,baseRefName,baseRepository,commits
   ```

   If this does not find a PR, query the target repository with `gh pr list`
   using the current branch name and report that no PR was found rather than
   guessing a number.
4. Confirm that the PR's head branch and repository match the checked-out
   branch and its push remote before collecting feedback.

## Collect review feedback

Fetch all review threads, not just the latest page. Use `gh api graphql` with
pagination and retain each thread's ID, resolution state, path, line
coordinates, author, body, URL, and timestamps. Include every comment in a
thread so follow-up context is not lost.

Also collect conversation comments and submitted reviews:

```bash
gh pr view <number> --comments
gh api repos/<owner>/<repo>/pulls/<number>/reviews --paginate
gh api repos/<owner>/<repo>/issues/<number>/comments --paginate
```

Separate unresolved review threads, actionable conversation requests, accepted
feedback, and informational discussion. Do not treat an already-resolved
thread as outstanding unless a later comment reopens the issue.

## Collect check status and logs

Fetch the PR's current checks and head SHA with `gh pr checks` and `gh api`.
Include successful, pending, queued, cancelled, skipped, neutral, and failed
checks in the status summary. Only failure conclusions are build failures to
resolve.

For provider-specific evidence, follow:

- [GitHub Actions check details](./GITHUB_ACTIONS.md)
- [Azure DevOps pipeline details](./AZURE_DEVOPS.md)

Use a subagent to fetch and review failing check logs and pipeline results.
Give it the PR identity, head SHA, failed-check list, and the relevant
provider instructions. Ask it to return concise evidence, likely causes
clearly marked as inference, affected files, and validation commands. Do not
duplicate that investigation in the main agent; incorporate the subagent's
report into the overall findings.

Inspect relevant repository files read-only when comments or logs identify a
likely location. Distinguish facts reported by GitHub or the external provider
from conclusions inferred from the code.

## Build and present the remediation plan

Before making any changes, report:

1. The PR number, URL, head/base branches, repositories, and remotes used.
2. Unresolved review threads and other actionable discussion, with links and
   the requested outcome.
3. A check-status table and concise evidence for every failed check, including
   workflow/pipeline, job or task, failed step, error excerpt, and log URL.
4. Any ambiguity that requires a product or implementation decision.
5. An ordered plan covering every feedback item and failed check. Each step
   must name affected files or systems, explain the change, and specify how it
   will be validated.
6. For every PR comment, explicitly state one disposition and the action that
   follows:
   - **Resolve and Thumbs Up**: implement the requested change, verify it,
     resolve the thread, and add only a Thumbs Up reaction when no written
     reply is needed.
   - **Leave Alone**: document why the comment is informational, already
     addressed, out of scope, or otherwise requires no code change, and leave
     the thread unresolved and without a reaction.

The plan must include this explicit warning:

> Agents must not write PR review comments or replies while resolving feedback
> or build failures. Humans write replies. An agent may add only a Thumbs Up
> reaction when feedback is accepted as-is and no written response is needed.

Present the plan to the user and wait for approval before implementing it. If
the user approves only part of the plan, execute only that part and preserve
the remaining items as outstanding work.
