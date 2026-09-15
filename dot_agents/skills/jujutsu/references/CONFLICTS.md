# Resolving Conflicts

jj treats conflicts as **first-class objects**: a commit can contain a conflict, and that conflict **persists through rebases** until someone resolves it. This is the headline mental-model difference from git, where a working tree must be conflict-free before committing.

For an agent, this changes the rhythm:

- A `jj rebase` or `jj squash` that produces a conflict **does not fail**. It succeeds; the resulting commit is just marked conflicted.
- You can keep working — even keep rebasing the conflicted commit further — and resolve it later.
- `jj` won't let you push a conflicted commit to a remote, so conflicts must be resolved before `jj git push`.

## Detecting conflicts

```bash
jj st                              # Shows "There are unresolved conflicts" if any
jj resolve --list                  # Lists all conflicted paths in @
jj resolve --list -r <change-id>   # Lists conflicts in a specific change
jj log                             # Conflicted changes are shown with a "conflict" marker
```

## Conflict marker formats

jj supports three marker styles (set via `ui.conflict-marker-style`):

- **`diff`** (modern default) — shows base→side as a diff
- **`snapshot`** — full content of each side, like git's `<<<<<<<` style
- **`git`** — legacy git-compatible 3-way

Check your style:

```bash
jj config get ui.conflict-marker-style
```

### Example: `diff` style

```
<<<<<<< Conflict 1 of 1
%%%%%%% Changes from base to side #1
-base content here
+side 1 content here
+++++++ Contents of side #2
side 2 content here
>>>>>>> Conflict 1 of 1 ends
```

- Side #1 = "ours" (the destination — typically your current branch/change)
- Side #2 = "theirs" (the source — typically what's being rebased/merged in)
- The `%%%%%%%` block shows what side #1 changed *from the common base*; side #2's content is shown directly.

### Example: `snapshot` style

```
<<<<<<< Conflict 1 of 1
+++++++ Contents of side #1
side 1 content here
%%%%%%% Contents of base
base content here
+++++++ Contents of side #2
side 2 content here
>>>>>>> Conflict 1 of 1 ends
```

Both styles delimit conflict regions identically. To resolve: replace the entire `<<<<<<< ... >>>>>>>` block with the desired final content.

## Five resolution paths (agent-friendly)

`jj resolve` with no `--tool` launches an interactive merge tool and **will hang in non-interactive agent environments**. Use one of these instead:

### 1. Edit conflict markers directly (most common)

Read the file, replace each `<<<<<<<` block with the resolved content, save. Then snapshot:

```bash
jj st     # Triggers snapshot; should report no remaining conflicts
```

This is the canonical agent path. Works for any merge complexity.

### 2. Take one side wholesale: `:ours` / `:theirs`

For conflicts where one side simply wins (e.g., a rebase brings in unrelated formatting changes you don't want):

```bash
jj resolve --tool :ours              # Keep side #1; drop side #2's conflicting changes
jj resolve --tool :theirs            # Keep side #2; drop side #1's conflicting changes

# Scope to specific paths
jj resolve --tool :ours path/to/file.rs
```

These built-in tools are **non-interactive** and safe to use in agent contexts. They apply to all conflicts in `@` (or the paths given).

### 3. Restore from a specific version: `jj restore --from`

When neither side is right but a *different* revision has the content you want:

```bash
jj restore --from <change-id> path/to/file.txt
```

This pulls the file contents from `<change-id>` into the working copy, replacing conflict markers entirely.

### 4. Abandon a hopelessly conflicted change

If the conflicted change wasn't worth keeping:

```bash
jj abandon <change-id>
```

Descendants are rebased onto the parent. Their own conflicts (if any) remain to be resolved separately.

### 5. Resolve at the ancestor, let jj re-propagate

If a rebase produced the same conflict in many descendants, **don't resolve each descendant individually**. Resolve once at the change where the conflict first appeared, and jj will re-propagate the resolution forward:

```bash
# Find where the conflict first appeared
jj log -r 'conflicts()'

# Edit that change directly
jj edit <ancestor-change-id>
# ... fix conflict markers ...
jj st                                # Snapshot the resolution
jj edit @-                           # Move back to where you were
```

Descendants pick up the resolution automatically.

## Verifying a resolution

After editing, **don't trust `jj st` alone**:

```bash
# 1. Status should report no conflicts
jj st

# 2. Grep for residual markers (catches typos that left markers in place)
git grep -E '^(<{7}|>{7}|\\%{7}|\\+{7})' || echo 'no residual conflict markers'

# 3. Run the project's tests/linter — markers may be syntactically valid in some
#    languages (e.g. inside strings) and parse-tests catch what eyeballing misses.
```

In a colocated repo, `git grep` is allowed (read-only). In a non-colocated repo, use `grep -rE` or `rg`.

## Pushing conflicted commits is blocked

```bash
jj git push -b main
# Refused: branch main contains conflicts
```

You'll need to resolve before pushing. There's no `--force-push-conflicts` option — this is by design.

## Anti-patterns

- ❌ **`jj resolve` (no `--tool`)** — interactive; will hang the agent. Always pass `--tool :ours` / `--tool :theirs` or edit markers manually.
- ❌ **Resolving descendants individually after a rebase** — wasteful and error-prone; resolve at the ancestor (path 5).
- ❌ **Relying on `jj st` to verify resolution** — also grep for residual markers and run tests.
- ❌ **Trying to `git checkout` to "drop" a conflict** in a colocated repo — corrupts jj state. Use `jj abandon` or resolve.
- ❌ **`jj squash` to "hide" a conflict into another commit** — the conflict propagates; it doesn't disappear.

## Quick reference

| Action | Command |
|---|---|
| List conflicts in `@` | `jj resolve --list` |
| List conflicts everywhere | `jj log -r 'conflicts()'` |
| Resolve manually | Edit file, then `jj st` |
| Take "ours" (side #1) | `jj resolve --tool :ours [paths...]` |
| Take "theirs" (side #2) | `jj resolve --tool :theirs [paths...]` |
| Restore from another rev | `jj restore --from <change-id> <path>` |
| Drop the change | `jj abandon <change-id>` |
| Find conflict's ancestor | `jj log -r 'conflicts() ~ ::conflicts()-'` |
| Check marker style | `jj config get ui.conflict-marker-style` |
