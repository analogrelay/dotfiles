---
name: pr-check
description: 'Inspect the current branch pull request, unresolved review feedback, and failing checks, then present a user-approved plan to address them. Use when the user asks to assess PR feedback, review unresolved comments, or investigate PR build failures before making changes.'
user-invocable: true
disable-model-invocation: false
---

# Plan Pull Request Feedback and Check Fixes

Inspect the pull request for the current branch and create a plan to resolve
unresolved feedback and build failures. Do not change local files, GitHub state,
or workflow runs while using this skill.

## Identify the pull request

1. Run `git remote -v` and record the fetch and push remotes. Use this to
   identify the GitHub owner and repository that the branch is expected to
   target, including fork remotes where applicable.
2. Use the GitHub CLI to find the current branch's pull request. Start with:

   ```bash
   gh pr view --json number,url,title,headRefName,baseRefName,headRepository,baseRepository
   ```

3. If that command cannot identify a pull request, use the remotes and the
   current branch name to query the appropriate repository with `gh pr list`.
   State clearly if no pull request can be found; do not guess a PR number.
4. Confirm that the PR's head branch and repository match the current branch
   and relevant remote before gathering feedback.

## Gather unresolved review feedback

Fetch all unresolved review threads with `gh api graphql`. Request the thread
ID, resolution state, path, line information, and every comment's author,
body, URL, and timestamp. Paginate until every review thread has been fetched,
then retain only threads whose `isResolved` value is false.

Also use `gh pr view` or `gh api` to collect the PR conversation comments and
reviews, so that requested changes recorded outside review threads are visible.
Distinguish unresolved review threads from general PR discussion in the
resulting plan.

## Investigate failed checks

1. Fetch all check results for the PR head SHA using `gh pr checks` and/or
   `gh api`. Capture each check's name, state, conclusion, URL, workflow, and
   check-run or workflow-run ID where available.
2. For every failed check, retrieve the available details:
   - Request check-run output and annotations through the GitHub API.
   - For GitHub Actions runs, use `gh run view <run-id> --log-failed` and
     `gh run view <run-id>` to capture failed-step output, job names, and run
     URLs.
   - For detailed GitHub Actions collection steps, follow
     [GitHub Actions check results](./GITHUB_ACTIONS.md).
   - For Azure DevOps pipeline checks, follow
     [Azure DevOps pipeline results](./AZURE_DEVOPS.md).
   - Follow linked external-check details when GitHub provides accessible text
     or annotations; otherwise record that the external provider did not
     expose enough diagnostic detail.
3. Include queued, pending, cancelled, skipped, and neutral checks in the
   status summary. Only treat checks with a failure conclusion as build
   failures to resolve.
4. Inspect relevant repository files read-only when failure output or feedback
   identifies a likely location. Separate GitHub-reported facts from
   inferences.

## Clarify and plan

1. For each unresolved thread or discussion item, determine whether the
   requested resolution is unambiguous from the feedback and code context.
2. Ask the user how they want to address feedback whenever the intended
   resolution is unclear, there are competing reasonable implementations, or
   accepting the feedback would alter product behavior or scope. Do not ask
   for clarification when a safe, direct correction is clearly specified.
3. Produce a concrete, ordered plan that covers every actionable unresolved
   feedback item and every failed build check. Each step must name the affected
   files or systems, explain the proposed change, and state how it will be
   validated.
4. The plan **must explicitly state that agents must NEVER reply to PR
   comments**. Agents may resolve a review thread without posting a comment
   only after implementing the proposed solution.
5. Present the findings and plan to the user for review before making any
   changes. Wait for approval or further direction before implementing it.

## Report format

Present:

1. The PR identity, head/base branches, and remotes used to identify it.
2. A grouped list of unresolved review threads and other actionable PR
   discussion, including links and the requested change.
3. A check-status summary and detailed failed-check evidence.
4. Any clarifying questions that are required before planning or
   implementation.
5. The ordered remediation plan, including the mandatory no-comment-response
   rule and validation for each step.
