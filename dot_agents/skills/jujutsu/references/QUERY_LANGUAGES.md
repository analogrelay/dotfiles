# Query Languages

Use jj's query languages when you need to select revisions, paths, or render compact output without falling back to the default verbose UI.

**Tested with jj 0.41.0**

## Revsets

Use revsets to select commits and workspaces.

Common selectors:

- `@`: current working-copy change
- `@-`: parent of the current working-copy change
- `trunk()`: configured mainline; use this instead of guessing `main` vs `master`
- `::@`: all ancestors of `@`
- `trunk()..@`: work reachable from `@` that is not on `trunk()`
- `working_copies()`: all workspace working-copy commits
- `<workspace>@`: another workspace's working-copy commit
- `<change-id>`: a stable change ID such as `wqzktpqm`

Agent patterns:

```bash
# Current work relative to trunk
jj --no-pager log -r 'trunk()..@'

# All active workspace tips
jj --no-pager log -r 'working_copies()'

# One specific workspace tip
jj --no-pager log -r '<workspace>@'
```

Quote revsets that contain punctuation or function calls.

## Filesets

Use filesets when a command should operate on only part of the tree.

Common patterns:

- `path` or `"path"`: cwd-relative path prefix
- `file:"path"`: exact cwd-relative file path
- `glob:"pattern"`: cwd-relative glob
- `root:"path"`: workspace-relative path prefix
- `~x`: everything except `x`
- `x & y`: intersection
- `x | y`: union
- `x ~ y`: subtract `y` from `x`

Examples:

```bash
# Only markdown files in the current directory
jj diff 'glob:"*.md"'

# Everything in src except snapshots
jj diff 'src ~ glob:"src/**/*.snap"'

# Exact file path
jj diff 'file:"README.md"'
```

## Templates

Use templates when default output is too large or too decorative for agent work.

Common building blocks:

- `++`: concatenate output pieces
- `if(cond, a, b)`: conditional formatting
- `description.first_line()`: one-line summary
- `change_id.shortest(8)`: stable short ID
- `bookmarks`: bookmark names for a commit
- `current_working_copy`, `empty`, `conflict`: useful booleans in `jj log`

Example:

```bash
jj --no-pager log --no-graph -n 5 -T 'change_id.shortest(8) ++ " " ++ if(description, description.first_line(), "(no description)") ++ "\n"'
```

Start from `references/TEMPLATES.md` instead of inventing new templates unless you need something substantially different.

## Rules

- Prefer `trunk()` over hardcoding `main` or `master`.
- Quote revsets and filesets in shell commands when punctuation could be interpreted by the shell.
- Prefer compact `jj --no-pager` inspection commands before widening the query.
- If a query fails to parse, check `jj <command> --help`, `jj help -k revsets`, `jj help -k filesets`, or `jj help -k templates`.
