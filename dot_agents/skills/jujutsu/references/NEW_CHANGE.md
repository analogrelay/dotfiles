# Starting a New Change

The jj workflow is: **describe first, then code, then refine**. The working copy is always a commit (`@`), so you're already in one when you start. The question is whether to reuse it or start fresh.

## The opening sequence

```bash
# 1. Check what @ currently looks like
jj st
```

**If `@` is empty** (no changes, no description set, or description is fine to discard):
- Reuse it. Just describe and start.

**If `@` has changes you want to keep** (it's someone else's WIP, or work you haven't finished):
- Start fresh with `jj new` — this creates a new empty commit on top of `@`.

```bash
# 2. Describe before coding (only with -m; never editor-based)
jj desc -m "feat: Add user authentication to login endpoint"

# 3. Make changes — they snapshot to @ automatically on the next jj command
#    (no `jj add`, no `jj commit` needed)

# 4. Verify
jj st
```

## Why describe first

Setting the message up front:
- Forces you to articulate the change as one logical unit before writing code (atomic commits)
- Means there's never a phase where `@` says "(no description set)"
- Makes the change navigable in `jj log` while it's still being built

See `references/COMMIT_MSG.md` for the message format conventions.

## After the change is done

**Do NOT run `jj new` to "close" the change.** In jj, the working copy is always a commit — there's no separate commit step. Leave `@` as-is; the *next* task's step 1 (`jj st` → reuse or `jj new`) handles transition.

If refinement is needed (split, squash, absorb, abandon), see `references/REFINE_COMMIT.md`.

## Anti-patterns

- ❌ `jj commit` — doesn't exist; the working copy is already a commit
- ❌ `jj desc` without `-m` — opens an editor; will hang in non-interactive agent environments
- ❌ Running `jj new` at the end of a task — leaves an empty `@` for the next agent to clean up
- ❌ Starting code before describing — you'll forget to describe, or describe vaguely after the fact
