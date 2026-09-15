### Squashing Changes

`jj squash` moves changes from one revision to another. The default is `@` → its parent; pass `--into` to target any other change.

```bash
# Default: squash @ into its parent
jj squash

# Squash @ into a specific change (not the parent)
jj squash --into <change-id>
jj squash -t <change-id>                  # short form

# Squash a non-@ change into its parent
jj squash -r <change-id>

# Full explicit form: any source, any destination
jj squash --from <source-id> --into <destination-id>

# Squash only specific paths (the rest stay in the source)
jj squash path/to/file.txt
jj squash --into <change-id> src/auth/
```

**Combined description prompt**: if both source and destination have non-empty descriptions, `jj squash` opens an editor to pick a combined description — and hangs in agent environments. Always pass `-m` inline when squashing two described commits together:

```bash
jj squash --into <change-id> -m "feat: Combine auth changes"
```

**Empty source**: when squashing leaves the source revision empty (no content vs. its parent), jj abandons it by default. Pass `--keep-emptied` to keep an empty placeholder instead.

**Interactive forms to avoid**: `jj squash -i` / `jj squash --interactive` open a TUI and will hang in agent environments. Use `--from` / `--into` / paths instead.

### Splitting Commits

**Warning**: `jj split` is interactive and will hang in agent environments. To divide a commit, use `jj restore` to move changes out, then create separate commits manually.

### Absorbing Changes

Automatically distribute changes to the commits that last modified those lines:

```bash
# Absorb working copy changes into appropriate ancestor commits
jj absorb
```

### Abandoning Commits

Remove a commit entirely (descendants are rebased to its parent):

```bash
jj abandon <change-id>
```

### Undoing Operations

Reverse the last jj operation:

```bash
jj undo
```

This reverts the repository to its state before the previous command. Useful for recovering from mistakes like accidental `abandon`, `squash`, or `rebase`.

### Restoring Files

Discard changes to specific files or restore files from another revision:

```bash
# Discard all uncommitted changes in working copy (restore from parent)
jj restore

# Discard changes to specific files
jj restore path/to/file.txt

# Restore files from a specific revision
jj restore --from <change-id> path/to/file.txt
