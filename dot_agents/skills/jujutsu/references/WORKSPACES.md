# Parallel Workspaces

Use `jj workspace` when multiple agents need independent working copies of the same repo. Each workspace gets its own `@` while sharing the same repo store and operation log.

**Tested with jj 0.41.0**

This skill intentionally prefers project-local workspace directories when they are safely ignored. Directory priority for this skill:

1. `.workspaces/`
2. `workspaces/`
3. Repo-local instructions such as `AGENTS.md` or `CLAUDE.md`
4. Ask the user

Do not replace this with a blanket "sibling directories only" rule.

## Before Creating a Workspace

First, make sure project-local workspaces will not leak into Git history:

```bash
grep -E '^\.?workspaces/?$' .gitignore 2>/dev/null
```

If the entry is missing, add it before `jj workspace add` and record that change using the normal workflow from `references/NEW_CHANGE.md`:

```bash
echo ".workspaces/" >> .gitignore
```

Never skip this check. `jj workspace add` creates directories that contain `.jj/` metadata, and the outer Git repo must ignore them.

Use descriptive names so `jj workspace list` and `jj log` stay readable:

```bash
REPO_NAME=$(basename "$(jj workspace root)")
WORKSPACE_PATH=".workspaces/${REPO_NAME}-<purpose>"
```

Examples:

- `.workspaces/myrepo-test-runner`
- `.workspaces/myrepo-reviewer-agent`
- `.workspaces/myrepo-refactor-experiment`

Avoid generic names such as `tmp`, `wip`, or `new`.

## Creating and Bootstrapping

Create the workspace and move into it:

```bash
jj workspace add "$WORKSPACE_PATH"
cd "$WORKSPACE_PATH"
```

After creation:

- the workspace has its own working-copy commit
- it appears in log output as `<workspace-name>@`
- it shares history and the operation log with the main workspace
- snapshots in this workspace affect only this workspace's `@`

If the repo needs environment setup, bootstrap it in the new workspace before handing it to another agent:

| Marker file | Setup command |
| --- | --- |
| `package.json` | `npm install` |
| `Cargo.toml` | `cargo build` |
| `pyproject.toml` | `uv sync` |
| `Gemfile` | `bundle install` |
| `flake.nix` | `nix develop` |
| `go.mod` | `go mod download` |
| `mix.exs` | `mix deps.get` |

## Agent Handoff

When one agent creates a workspace for another, always report:

- the absolute workspace path
- the change ID the agent should edit
- the exact `cd` command
- the exact `jj edit <change-id>` command
- the scope boundaries

Use a handoff like this:

```text
Workspace: /absolute/path/to/.workspaces/myrepo-tests
Change ID: abcdefgh

cd /absolute/path/to/.workspaces/myrepo-tests
jj edit abcdefgh

Rules:
- Always use -m for messages.
- Run jj st after every mutation.
- Do not modify files outside the assigned scope.
```

Absolute paths matter. Agents lose track of relative locations more often than they lose track of change IDs.

## Monitoring Progress

Start from the compact `jj log` command in `references/TEMPLATES.md`, then swap in the revset you need:

- all workspace tips: `-r 'working_copies()'`
- one named workspace: `-r '<workspace>@'`

Examples of the revsets themselves:

```bash
working_copies()
reviewer@
```

See `references/QUERY_LANGUAGES.md` for the revset syntax behind those examples.

## Combining Results

When a workspace finishes its work, bring that change back to the main line and retire the workspace. Do not decide silently; ask the user which strategy they want.

### Strategy 1: Rebase into the Default Workspace

Use this when one developer is orchestrating multiple agents and the result should land as ordinary commits in the default workspace.

```bash
jj rebase -s <workspace-change-id> -d @
jj workspace forget <workspace-name>
rm -rf "$WORKSPACE_PATH"
```

If the repo uses bookmarks for shipping work, move or create the bookmark after the rebase using the normal push workflow from `references/PUSH.md`.

### Strategy 2: Keep an Explicit Merge

Use this when both lines of work are independently meaningful and the merge structure should remain visible:

```bash
jj new <change-from-workspace-a> <change-from-workspace-b> -m "merge: combine parallel work"
```

### Strategy 3: Push a Bookmark and Open a PR

Use this when the work needs human review before landing:

```bash
jj bookmark create my-feature -r <workspace-change-id>
jj git push -b my-feature
```

Decision guide:

| Situation | Default suggestion |
| --- | --- |
| Solo developer running multiple local agents | Strategy 1 |
| Long-lived feature with checkpoints | Strategy 1, then push a bookmark when ready |
| Human review required | Strategy 3 |
| Both lines of work are independently meaningful | Strategy 2 |

If the context is ambiguous, suggest Strategy 1 first and ask whether the user wants the result to land in the default workspace or as a PR.

## Listing and Cleaning Up

```bash
jj workspace list
jj workspace forget <workspace-name>
rm -rf "$WORKSPACE_PATH"
```

If you need to inspect `jj workspace list` output as an agent, use the compact command from `references/TEMPLATES.md`.

`jj workspace forget` only unregisters the workspace. It does not delete files from disk.

## `update-stale`

If another workspace rewrites the commit your workspace had checked out, jj marks that workspace as stale. Use this first:

```bash
jj workspace update-stale
jj st
```

Do not improvise a manual repair before trying `update-stale`. If the old operation is gone, jj can create a recovery commit with the current working-copy contents instead of silently discarding them.

## Conflict Avoidance

| Risk | Recommended mitigation |
| --- | --- |
| Build outputs or generated files | Ignore them or give each workspace separate output paths |
| Shared config files | Assign a single owner for that file or change it serially |
| Lockfiles / dependency updates | Let one task own dependency changes |
| Same source files across workspaces | Redesign the task boundary or serialize the work |

## Critical Rules

1. Never skip the `.gitignore` check for project-local workspace directories.
2. Always follow the directory priority: `.workspaces/` -> `workspaces/` -> repo instructions -> ask.
3. Use descriptive names: `${REPO_NAME}-<purpose>`, not `tmp`.
4. Bootstrap the workspace before handing it to another agent.
5. Report the absolute path, change ID, and next commands when a workspace is ready.
6. Run `jj workspace forget` before deleting the directory.
7. Ask before choosing between rebase, merge, or PR integration.
8. Use `jj workspace update-stale` as the first response to a stale workspace.

## Reference

Convention adapted from [edmundmiller/dotfiles `using-jj-workspaces`](https://lobehub.com/skills/edmundmiller-dotfiles-using-jj-workspaces).

Additional handoff, monitoring, stale-workspace, and conflict-avoidance patterns were adapted from [joshuadavidthomas/agent-skills `jj`](https://github.com/joshuadavidthomas/agent-skills/tree/main/jj) and its [`workspaces.md`](https://raw.githubusercontent.com/joshuadavidthomas/agent-skills/main/jj/workspaces.md), while intentionally preserving this skill's local `.workspaces/` / `workspaces/` directory priority and local change-creation workflow.
