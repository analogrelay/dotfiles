# Recovery and the Operation Log

The **operation log** records every mutation to the repo — every `jj` command that changed state. Nothing is ever truly lost. This is jj's safety net: an agent that makes a mistake (bad squash, accidental abandon, wrong rebase) can always go back.

## The three recovery primitives

### 1. `jj undo` — reverse the last operation

```bash
jj undo
```

The first thing to reach for. Reverses the most recent operation atomically — works for `abandon`, `squash`, `rebase`, `restore`, `describe`, and most other mutations.

**Prefer `jj undo` over manually reversing changes** — it's always correct and safe.

### 2. `jj op log` — see the full operation history

```bash
jj op log                          # All operations, newest first
jj op log -n 20                    # Limit to 20
jj op log -p                       # Include diffs of what each op changed
```

If you are inspecting first and do not yet need full diffs, start with the compact `jj op log` command from `references/TEMPLATES.md`. Add `-p` only after you have narrowed the relevant op IDs.

Each operation has an `op-id`. Use these to navigate further back than a single `jj undo`.

### 3. `jj op restore` — jump to any past state

```bash
jj op restore <op-id>
```

Restores the entire repo to the state it was in at that op. **This is the nuke-from-orbit recovery** — it can undo many operations at once. Safe because the restore itself becomes a new op in the log (you can `jj undo` it if you change your mind).

## Per-change history: `jj evolog`

The op log shows everything; `jj evolog` shows how a *single change* evolved (was rewritten, squashed into, rebased, etc.):

```bash
jj evolog                          # Evolution of the current @
jj evolog -r <change-id>           # Evolution of a specific change
jj evolog -p                       # Include patches between versions
```

If you are inspecting first and do not yet need patches, start with the compact `jj evolog` command from `references/TEMPLATES.md`. Add `-p` only after you have narrowed the relevant version.

Useful when you want to recover an earlier *version* of a specific commit (e.g., "what did this commit look like before I squashed into it?").

## Common recovery scenarios

### Accidentally abandoned the wrong change

```bash
jj undo                # If it was just now
# or
jj op log              # Find the abandon op
jj op restore <op-id>  # Restore to before it
```

### A `jj squash` merged work into the wrong parent

```bash
jj undo                # Single-step undo
```

If you've done more work since:

```bash
jj op log              # Locate the squash op
jj op restore <op-id>  # Jump back; ops after that point are dropped
```

### A rebase went sideways

```bash
jj undo                # Reverse the rebase entirely
```

### Lost work after a complex sequence

```bash
jj op log -p           # Diffs show exactly what each op did
                       # Find the op id where the work still existed
jj op restore <op-id>
```

### Need a previous version of a commit's content

```bash
jj evolog -r <change-id> -p              # Find the version you want
jj restore --from <commit-id-from-evolog> <path>   # Restore working-copy content from it
```

### Restored the wrong op-id

```bash
jj undo                # The restore is itself a recorded op
```

## Notes for agents

- **Always reach for `jj undo` first** when something looks wrong. Don't try to manually unwind with new commits or `jj abandon` — `undo` is the canonical safe path.
- **The op log isn't pruned aggressively** — even a week of work is fully retrievable.
- **`jj op restore` is recorded** — it's not destructive in the way `git reset --hard` is. You can always undo a restore.
- **There is no stash/pop in jj** because every state is automatically a commit in the op log. Treat `jj undo` / `jj op restore` as the equivalent.

## Quick reference

| Action | Command |
|---|---|
| Undo last operation | `jj undo` |
| See all operations | `jj op log` |
| See ops with diffs | `jj op log -p` |
| Jump to past state | `jj op restore <op-id>` |
| Change evolution | `jj evolog -r <change-id>` |
| Restore file from past version | `jj restore --from <commit-id> <path>` |
