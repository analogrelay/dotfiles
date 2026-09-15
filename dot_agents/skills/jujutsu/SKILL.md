---
name: jujutsu
description: Use this skill for any version control operations (commit, log, diff, push, fetch, bookmark, workspace, rebase, undo, etc.). If a `.jj` directory exists, the repo is jujutsu and git mutations will corrupt it — use `jj` for all mutations; read-only `git log/diff/show/blame/grep` are allowed. Covers co-located repos, multi-agent parallel workspaces, and operation-log recovery. **DO NOT IGNORE**
allowed-tools: Bash(jj *)
license: Apache-2.0
metadata:
  author: johnstegeman
  version: "1.3"
---

# Jujutsu (jj) Version Control System

This skill helps you work with Jujutsu, a Git-compatible VCS with mutable commits and automatic rebasing.

**Tested with jj v0.41.0** - Commands may differ in other versions.

For token-sensitive inspection commands, prefer the compact commands in `references/TEMPLATES.md` over jj's default output.

The compact commands in `references/TEMPLATES.md` intentionally use `jj --no-pager ...`.

For revsets, filesets, and template syntax, see `references/QUERY_LANGUAGES.md`.

For sibling or unrelated work that should start from `trunk()`, see `references/NONLINEAR.md`.

For common surprises and easy mistakes, see `references/GOTCHAS.md`.

<!--
Attribution and inspiration sources:

- Forked from danverbraganza/jujutsu-skill (https://skills.sh/danverbraganza/jujutsu-skill/jujutsu).
  The original scaffolding, references/ structure, and core mental-model wording are from there.

- Enforcement language in "Critical: never use git for mutations" was tightened using the
  read-only-git allowlist pattern from knoopx/pi@jujutsu
  (https://skills.sh/knoopx/pi/jujutsu).

- "Parallel Workspaces" framing as a tool for multi-agent isolation draws on
  onevcat/skills@onevcat-jj (https://skills.sh/onevcat/skills/onevcat-jj),
  which is explicitly subtitled "Version Control for Agent Workflows".

- The .workspaces/ project-local directory convention, the .gitignore safety check,
  and the directory-selection priority documented in references/WORKSPACES.md
  come from edmundmiller/dotfiles using-jj-workspaces
  (https://lobehub.com/skills/edmundmiller-dotfiles-using-jj-workspaces).

- The "op log records every mutation; nothing is ever truly lost" framing in the
  Recovery section is adapted from trevors/dot-claude@jj-workflow
  (https://skills.sh/trevors/dot-claude/jj-workflow).

- Query-language guidance, nonlinear-work patterns, and workspace handoff /
  monitoring ideas were adapted from joshuadavidthomas/agent-skills `jj`
  (https://github.com/joshuadavidthomas/agent-skills/tree/main/jj) and its
  `workspaces.md`
  (https://raw.githubusercontent.com/joshuadavidthomas/agent-skills/main/jj/workspaces.md),
  while intentionally preserving this skill's local describe-first workflow and
  `.workspaces/` / `workspaces/` directory priority.
-->


## Detecting a jj repo

Check whether a directory is part of a jj repo:

```bash
jj root
```

If it returns a path, the repo is jj-managed. If it returns `Error: There is no jj repo in <directory>`, it isn't. The presence of a `.jj/` folder is another giveaway. If the repo is not a jj one, do not further use this skill.

<!-- Enforcement wording (allowed/forbidden split with read-only git allowlist) adapted from knoopx/pi@jujutsu. -->
## Critical: never use git for mutations in a jj repo

In a jj repo (including co-located repos that also have `.git/`):

- **Forbidden** (corrupts jj state): `git commit`, `git add`, `git stash`, `git reset`, `git checkout <branch>`, `git switch`, `git rebase`, `git merge`, `git cherry-pick`, `git push`, `git pull`.
- **Allowed** (read-only): `git log`, `git show`, `git diff`, `git blame`, `git grep`, `git status`. Prefer the `jj` equivalents (`jj log`, `jj show`, `jj diff`, etc.) but read-only git commands won't break anything.
- **Use jj instead**: `jj git push`, `jj git fetch`, `jj edit <change>` (not `git checkout`), `jj rebase`, `jj new <a> <b>` (for merges).

See `references/COLOCATED.md` for the full co-located repo workflow.

## Important: Automated/Agent Environment

When running as an agent or running on behalf of the user:

1. **Always use `-m` flags** to provide commit messages inline rather than relying on editor prompts:

```bash
# Always use -m to avoid editor prompts
jj desc -m "message"               # NOT: jj desc
jj squash --into @- -m "message"   # NOT: jj squash (which opens editor or prompts for hunks)
```

Editor-based commands will fail in non-interactive environments.

2. **Verify operations with `jj st`** after mutations (`squash`, `abandon`, `rebase`, `restore`) to confirm the operation succeeded.

## Important Principles

1. Each commit should represent one logical change. See [commit messages](references/COMMIT_MSG.md) for details on good commit messages. Before starting work on a new change, make sure the working copy is clean (no changes)

```bash
jj st
```

## Core Concepts

### The Working Copy is a Commit

In jj, your working directory is always a commit (referenced as `@`). Changes are automatically snapshotted when you run any jj command. There is no staging area.

There is no need to run `jj commit`.

### Commits Are Mutable

**CRITICAL**: Unlike git, jj commits can be freely modified. This enables a high-quality commit workflow:

1. Before starting work, run `jj st`. If `@` already has changes, run `jj new` first. If `@` is empty, use it as-is.
2. Describe your intended changes with `jj desc -m "Message"`
3. Make your changes.
4. Do NOT run `jj new` when finished — leave that to the next task's step 1.

You may refine the commit using `jj squash` or `jj absorb` as needed

### Change IDs vs Commit IDs

- **Change ID**: A stable identifier (like `tqpwlqmp`) that persists when a commit is rewritten
- **Commit ID**: A content hash (like `3ccf7581`) that changes when commit content changes

Prefer using Change IDs when referencing commits in commands.

## Essential Workflow

### Starting Work: Describe First, Then Code

**Always create your commit message before writing code:**

```bash
# First, describe what you intend to do
jj desc -m "feat: Add user authentication to login endpoint"

# Then make your changes - they automatically become part of this commit
# ... edit files ...

# Check status
jj st
```

For the full starting-a-change workflow (when to reuse `@` vs `jj new`, anti-patterns, decision logic), see `references/NEW_CHANGE.md`.

For unrelated or sibling work that should branch from `trunk()`, see `references/NONLINEAR.md`.

### Creating Atomic Commits

Each commit should represent ONE logical change.

### Viewing History

```bash
# View recent commits
jj log

# View with patches
jj log -p

# View specific commit
jj show <change-id>

# View diff of working copy
jj diff
```

If you need to run `jj log`, `jj show`, or `jj diff` as an agent, use the matching compact command from `references/TEMPLATES.md` unless the full default output is explicitly needed.

For the revsets, filesets, and template syntax behind those compact commands, see `references/QUERY_LANGUAGES.md`.

### Moving Between Commits

```bash
# Create a new empty commit on top of current
jj new

# Create new commit with message
jj new && jj desc -m "Commit message"

# Edit an existing commit (working copy becomes that commit)
jj edit <change-id>

# Edit the previous commit
jj prev -e

# Edit the next commit
jj next -e
```

## Refining Commits

If you need to refine a commit (squash, abandon, undo, split, etc), see (Refining commits)[references/REFINE_COMMIT.md]

## Working with Bookmarks (Branches)

Bookmarks are jj's equivalent to git branches:

```bash
# Create a bookmark at current commit
jj bookmark create my-feature -r@

# Move bookmark to a different commit
jj bookmark move my-feature --to <change-id>

# List bookmarks
jj bookmark list

# Delete a bookmark
jj bookmark delete my-feature
```

If you need to run `jj bookmark list`, use the matching compact command from `references/TEMPLATES.md`.

<!--
Multi-agent workspace framing inspired by onevcat/skills@onevcat-jj.
The .workspaces/ project-local convention codified in references/WORKSPACES.md
is adapted from edmundmiller/dotfiles using-jj-workspaces.
-->
## Parallel Workspaces

For running multiple agents in parallel against the same repo without working-copy collisions, use `jj workspace`. Each workspace gets its own `@` while sharing the underlying repo store.

```bash
# Quick reference (full convention in references/WORKSPACES.md)
jj workspace add .workspaces/<repo>-<purpose>   # Create
jj workspace list                                # List
jj workspace forget <name>                       # Untrack (files stay on disk)
```

If you need to run `jj workspace list`, use the matching compact command from `references/TEMPLATES.md`.

See `references/WORKSPACES.md` for the full convention: the `.workspaces/` directory layout, `.gitignore` safety check, naming, environment bootstrapping, agent handoff, monitoring, stale-workspace recovery, and merging results from multiple workspaces back together.

## Working with tags

jujutsu does not yet support tags and pushing them to a remote. If you need to tag (such as for a release), you will need to use git to create and push the tags.

## Git Integration (Co-located Repos)

Always use co-located repos when working with existing git projects. They give you jj locally while keeping the repo remote-compatible with git tooling.

```bash
jj git clone <url> --colocate           # Clone a git repo
jj git init --colocate                  # Adopt an existing git repo
```

See `references/COLOCATED.md` for the complete workflow: the mutation rule (`git` is forbidden for mutations, allowed read-only), the git-command allowlist, common gotchas, and switching modes when absolutely necessary.

See `references/GOTCHAS.md` when the behavior feels surprising and you want the short list of jj-specific footguns before trying a git-style workaround.

### Pushing Changes

For pushing bookmarks to a remote, see `references/PUSH.md`. For named remotes, fork+upstream setups, and other multi-remote workflows, see `references/REMOTES.md`.

## Handling Conflicts

jj treats conflicts as first-class objects — a commit can contain a conflict, and that conflict persists through rebases until resolved. `jj` refuses to push conflicted commits, so they must be resolved before `jj git push`.

```bash
jj st                                # Reports if @ has unresolved conflicts
jj resolve --list                    # Lists conflicted paths
jj resolve --tool :ours              # Take side #1 non-interactively (agent-safe)
jj resolve --tool :theirs            # Take side #2 non-interactively (agent-safe)
```

**Never run bare `jj resolve` (no `--tool`)** — it's interactive and will hang in non-interactive agent environments. Either pass `--tool :ours` / `--tool :theirs`, or edit conflict markers directly in the file and let `jj st` snapshot the resolution.

See `references/CONFLICTS.md` for the full resolution playbook: marker formats (diff vs snapshot), five resolution paths, ancestor-level resolution to avoid re-resolving across descendants, verification (beyond `jj st`), and anti-patterns.

<!-- Recovery framing ("op log records every mutation; nothing is ever lost") adapted from trevors/dot-claude@jj-workflow. -->
## Recovery and the Operation Log

The op log records every mutation. Nothing is ever lost.

```bash
jj undo                  # Reverse the last operation (primary recovery tool)
jj op log                # See all operations
jj op restore <op-id>    # Jump back to any past state
jj evolog -r <change>    # See how a specific change evolved
```

If you need to run `jj op log` or `jj evolog`, use the matching compact commands from `references/TEMPLATES.md` first. Add `-p` only after you have narrowed the scope.

**Always reach for `jj undo` first** when something looks wrong — it's always correct and safe. See `references/RECOVERY.md` for recovery patterns by scenario (bad squash, accidental abandon, lost work, etc.).

## Preserving Commit Quality

**IMPORTANT**: Because commits are mutable, always refine them:

1. **Review your commit**: `jj show @` or `jj diff`
2. **Is it atomic?** One logical change per commit
3. **Is the message clear?** Use imperative verb phrase in sentence case format with no full stop: "Verb object"
4. **Are there unrelated changes?** Use `jj restore` to move changes out, then create separate commits
5. **Should changes be elsewhere?** Use `jj squash` or `jj absorb`

## Quick Reference

| Action | Command |
|--------|---------|
| Describe commit | `jj desc -m "message"` |
| View status | `jj st` |
| View log | `jj log` |
| View diff | `jj diff` |
| New commit | `jj st` then `jj new` only if `@` has changes, then `jj desc -m "message"` |
| Edit commit | `jj edit <id>` |
| Squash to parent | `jj squash --into @- -m "message"` |
| Auto-distribute | `jj absorb` |
| Abandon commit | `jj abandon <id>` |
| Undo last operation | `jj undo` |
| Restore files | `jj restore [paths]` |
| Create bookmark | `jj bookmark create <name>` |
| Push bookmark | `jj git push -b <name>` |
| Add workspace | `jj workspace add .workspaces/<repo>-<purpose>` |
| List workspaces | `jj workspace list` |
| Forget workspace | `jj workspace forget <name>` |
| See operation log | `jj op log` |
| Jump to past state | `jj op restore <op-id>` |
| See change evolution | `jj evolog -r <id>` |

## Best Practices Summary

1. **Describe first**: Set the commit message before coding
2. **One change per commit**: Keep commits atomic and focused
3. **Use change IDs**: They're stable across rewrites
4. **Refine commits**: Leverage mutability for clean history
5. **Embrace the workflow**: No staging area, no stashing — the op log replaces both
6. **Workspaces for parallel agents**: Isolate concurrent agent work in `.workspaces/<repo>-<purpose>` (see `references/WORKSPACES.md`)
7. **`jj undo` first**: When something looks wrong, undo before fixing manually (see `references/RECOVERY.md`)
