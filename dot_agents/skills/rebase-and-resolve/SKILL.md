---
name: rebase-and-resolve
description: Rebase the current branch onto the repository's latest upstream main or master branch and resolve conflicts, asking the user about ambiguous resolutions.
user-invocable: true
disable-model-invocation: false
---

# Rebase and Resolve

Update the current branch from the repository's canonical base remote, then
rebase it onto that remote's `main` or `master` branch. Do not substitute
another branch unless the user names it explicitly.

## Identify the workflow and upstream remote

1. Inspect the configured remotes and the current branch:

   ```bash
   git remote -v
   git branch --show-current
   ```

2. If an `upstream` remote exists, this is the **fork workflow**: use
   `upstream` as the `<target-remote>`. If there is no `upstream` but an
   `origin` remote exists, this is the **standard workflow**: use `origin` as
   the `<target-remote>`.
3. If neither remote exists, stop and report that a canonical remote could not
   be identified. Do not invent a remote or rewrite remote configuration.
4. Preserve the distinction between fetch and push URLs. Only the selected
   remote's fetch URL is relevant to this operation.

## Select and fetch the base branch

1. Query the selected remote's branch refs without fetching unrelated branches:

   ```bash
   git ls-remote --heads <target-remote> refs/heads/main
   ```

2. Assume the selected remote has a `main` branch. Fetch it:

   ```bash
   git fetch <target-remote> main
   ```

3. If fetching `main` fails because that branch does not exist, retry with
   `master`:

   ```bash
   git fetch <target-remote> master
   ```

4. If both fetches fail, stop and report that the remote has no supported base
   branch. Do not use a similarly named or default branch automatically.
5. Fetch only the selected base branch. Do not fetch all branches, tags, or
   unrelated refs as part of this skill.

## Rebase and resolve conflicts

1. Confirm the worktree is in a state where a rebase can safely start. Do not
   discard, stash, or overwrite uncommitted user changes. If local changes
   would prevent a safe rebase, stop and report the blocker.
2. Rebase the current branch onto the fetched remote-tracking branch:

   ```bash
   git rebase <target-remote>/<base-branch>
   ```

3. When conflicts occur, inspect each conflict and the surrounding history.
   Resolve a conflict yourself only when the intended result is unambiguous
   from the current branch, the upstream change, and established repository
   conventions. Preserve both sides when they are additive and compatible.
4. After each resolution, stage only the intended files and continue:

   ```bash
   git add <resolved-files>
   git rebase --continue
   ```

   Use the repository's normal non-interactive commit-message mechanism if the
   editor opens. Never use `git add -A` merely to make a rebase continue.
5. If the correct behavior, ownership, or user intent is ambiguous, stop with
   the rebase paused. Report the conflicting files, relevant competing
   changes, and the specific decision needed from the user. Do not guess and
   do not abort the rebase unless the user asks.
6. If a conflict is caused by generated output, use the repository's documented
   regeneration command rather than hand-editing generated files.

## Verify completion

After the rebase completes:

```bash
git status --short --branch
git log --oneline --decorate -n 5
git diff <target-remote>/<base-branch>...HEAD
```

Confirm that the current branch is based on the selected upstream branch, no
unresolved conflict markers remain, and no unrelated files changed. Run the
smallest repository-provided validation relevant to the resolved files when
one is available. Report any validation failure instead of presenting the
rebase as complete.
