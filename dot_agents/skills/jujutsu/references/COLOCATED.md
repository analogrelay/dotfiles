# Co-located jj + git Repositories

A **co-located** repo has both `.jj/` and `.git/` at the same root. jj manages local operations; git stays in sync underneath so remote-side tooling (CI, GitHub, hooks, IDE plugins, `gh` CLI) continues to work normally.

This is the **strongly recommended** setup for working with an existing git project.

## Why co-located

- **Local: jj's superior model.** Mutable commits, no staging area, the op log as a safety net.
- **Remote: still git.** GitHub sees ordinary commits and refs. Collaborators don't need to know you use jj.
- **Tooling parity.** IDE git integrations, pre-commit hooks, `gh`/`git` CLI for read-only inspection all continue to work.

## Creating a co-located repo

```bash
# From scratch
jj git init --colocate

# From a remote
jj git clone <url> --colocate

# Adopt an existing git repo (run from inside it)
cd existing-git-repo
jj git init --colocate
```

After this, both `.jj/` and `.git/` exist and stay synchronized automatically. **Never run `jj git init` without `--colocate`** on a project you already have git history for — non-colocated init creates a separate git store inside `.jj/repo/store/git` which is harder to work with.

## The mutation rule

> **Never use `git` for mutations in a co-located jj repo.** Read-only `git` is fine.

| git command | Allowed in jj repo? |
|---|---|
| `git log`, `git show`, `git diff`, `git blame`, `git grep` | ✅ Allowed (jj equivalents preferred) |
| `git status` | ✅ Allowed (shows git's view; may differ from `jj st`) |
| `git commit`, `git add`, `git stash`, `git reset` | ❌ Forbidden — corrupts jj state |
| `git checkout <branch>`, `git switch` | ❌ Forbidden — use `jj edit` instead |
| `git rebase`, `git merge`, `git cherry-pick` | ❌ Forbidden — use `jj rebase`, `jj new <a> <b>`, `jj duplicate` |
| `git fetch` | ⚠️ Use `jj git fetch` — it keeps jj in sync |
| `git pull` | ❌ Forbidden — `git pull` does fetch+merge; use `jj git fetch` + `jj rebase` |
| `git push` | ❌ Forbidden — use `jj git push -b <bookmark>` |

The reason: jj snapshots the working copy on every jj command. If git mutates state behind jj's back, jj's next snapshot will be confused about what changed when, and the op log can get out of sync.

## Switching to git mode (rare; usually a smell)

If you genuinely need to use a git workflow for one operation (e.g., an external tool insists), do it carefully:

```bash
# 1. Ensure jj working copy is committed and clean
jj st
# (resolve anything pending — describe, refine, etc.)

# 2. Now run the git operation
git <something>

# 3. Return to jj — jj will re-sync on the next command
jj st                   # Triggers re-sync
jj edit <change-id>     # Resume work
```

**Almost every git operation has a jj equivalent that's safer.** Reach for git mode only as a last resort.

## Common gotchas

- **Git complains about uncommitted changes**: jj's working copy is always a commit; git sees that as "uncommitted." Use `jj st` (not `git status`) to assess state.
- **HEAD detachment**: jj manages `HEAD` per change. `git checkout` will detach HEAD in confusing ways — use `jj edit` instead.
- **`.gitignore` is respected by jj** automatically. `.jjignore` is only needed if you want jj-only ignore patterns the outer git doesn't see.
- **Branches vs bookmarks**: git branches become jj bookmarks on fetch. Bookmarks don't auto-advance like git branches — you must `jj bookmark move` before pushing.

## Pushing from a co-located repo

Use `jj git push`, not `git push`:

```bash
jj bookmark move main --to @         # Move bookmark to your latest change
jj git push -b main                  # Push to remote
```

See `references/PUSH.md` for the full push workflow.
