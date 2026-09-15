# Gotchas

Short list of jj behaviors that regularly surprise agents.

**Tested with jj 0.41.0**

## 1. Working Copy Is a Commit

`@` is always a commit, not a staging area. `jj new` starts a different change; it does not finish the current one.

## 2. Most jj Commands Snapshot the Working Copy

Running `jj st`, `jj log`, and many other commands can record filesystem changes into the working-copy commit. If you intentionally need a stale view, use `--ignore-working-copy`.

## 3. Change IDs and Commit IDs Are Different

Change IDs are stable across rewrites. Commit IDs change whenever content or metadata changes. Prefer change IDs when handing work to another agent.

## 4. `jj undo` Is the First Recovery Tool

Do not manually reverse a bad `rebase`, `squash`, or `abandon` before trying `jj undo`. Use `references/RECOVERY.md` for deeper recovery.

## 5. Pager Output Is Not a Good Agent Default

Use the compact commands in `references/TEMPLATES.md`. Those commands intentionally use `jj --no-pager ...`.

## 6. Co-located Repos Still Forbid Git Mutations

`git log`, `git show`, `git diff`, `git blame`, `git grep`, and `git status` are fine. `git commit`, `git add`, `git rebase`, `git push`, and similar mutations can corrupt jj state.

## 7. `jj workspace forget` Does Not Delete Files

It only unregisters the workspace. Delete the directory separately if cleanup is intended.

## 8. Stale Workspaces Are Normal in Parallel Work

If another workspace rewrites your base, use `jj workspace update-stale`. Verify the result with `jj st` instead of improvising a manual repair.

## 9. Bare `jj resolve` Is Interactive

For agent-safe conflict handling, use `jj resolve --tool :ours`, `jj resolve --tool :theirs`, or edit conflict markers directly.

## 10. Default Output Is Often Too Large

Prefer compact templates, targeted revsets, and narrow filesets before reaching for full `jj log -p` or `jj show`.

When behavior feels surprising, stop and check `references/NEW_CHANGE.md`, `references/TEMPLATES.md`, `references/WORKSPACES.md`, or `references/RECOVERY.md` before inventing a git-style workaround.
