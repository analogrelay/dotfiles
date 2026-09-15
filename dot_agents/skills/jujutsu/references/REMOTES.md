# Named Remotes and Multi-Remote Workflows

For pushing to a single remote (the common case), see `references/PUSH.md`. This file covers everything else: managing named remotes, selecting which remote to push to, tracking remote bookmarks, and the two canonical multi-remote setups.

## Named remotes

When a repo has more than one remote (e.g. `origin` = your fork, `upstream` = the canonical source), you select the target with `--remote <name>`.

```bash
jj git remote list                            # See all remotes and their URLs
jj git remote add upstream <url>              # Add a second remote
jj git remote rename origin fork              # Rename a remote
jj git remote set-url origin <new-url>        # Change a remote's URL
jj git remote remove old-name                 # Remove a remote (and forget its bookmarks)
```

**Default remote selection**: when `--remote` is omitted, `jj git push` uses:

1. The `git.push` config setting (if set), or
2. The remote named `origin` (if multiple remotes exist), or
3. The single remote (if only one exists)

There is **no built-in option to push to multiple remotes in one command** — call `jj git push` once per remote.

### Pushing the same bookmark to two remotes

```bash
jj bookmark move my-feature --to @            # Move the bookmark to current change
jj git push -b my-feature --remote fork       # Push to your fork
jj git push -b my-feature --remote upstream   # Push to canonical (e.g. for a PR target branch)
```

### Setting a default remote

To avoid typing `--remote` repeatedly:

```bash
# Per-repo (writes to .jj/repo/config.toml)
jj config set --repo git.push fork

# Globally (writes to ~/.config/jj/config.toml)
jj config set --user git.push origin
```

### Tracking a remote bookmark

By default, when you `jj git fetch`, remote bookmarks appear as `<name>@<remote>` (e.g. `main@upstream`). To get a local bookmark that follows it:

```bash
jj bookmark track main@upstream               # Track upstream/main as a local 'main'
jj bookmark track 'glob:release/*@upstream'   # Track all upstream release branches
```

Once tracked, `jj git push --tracked --remote upstream` will push all tracked bookmarks back to that remote.

### Fetching from a specific remote

```bash
jj git fetch --remote upstream                # Fetch only from upstream
jj git fetch --all-remotes                    # Fetch from every configured remote
```

### When a push is rejected

If the remote has moved since your last fetch, `jj git push` refuses (similar to `git push --force-with-lease`). Re-sync first:

```bash
jj git fetch --remote <name>                  # Pull the remote's current state
# (resolve any bookmark conflicts or rebase if needed)
jj git push -b <bookmark> --remote <name>     # Try again
```

### Quick reference

| Action | Command |
|---|---|
| List remotes | `jj git remote list` |
| Add a remote | `jj git remote add <name> <url>` |
| Push to specific remote | `jj git push -b <bookmark> --remote <name>` |
| Push all tracked bookmarks to a remote | `jj git push --tracked --remote <name>` |
| Set default push remote (repo) | `jj config set --repo git.push <name>` |
| Track a remote bookmark | `jj bookmark track <name>@<remote>` |
| Fetch one remote | `jj git fetch --remote <name>` |
| Fetch all remotes | `jj git fetch --all-remotes` |

## Common multi-remote workflows

Two canonical setups documented in [the jj docs](https://docs.jj-vcs.dev/latest/guides/multiple-remotes/). Pick the one that matches your relationship to the remotes; the config is one-time per repo.

**Nomenclature** (jj convention):
- `origin` = a remote you have write access to (typically where you push)
- `upstream` = the more canonical / well-known repo (you may not have push access)
- Trunk is assumed to be `main`, so remote bookmarks are `main@origin` and `main@upstream`

### Scenario 1: GitHub-style fork contributing upstream

`upstream` is the canonical project; `origin` is your fork; you open PRs from `origin` against `upstream`.

Typical actions:
- Fetch from `upstream` to get the latest changes
- Push `main` to `origin` to keep your fork's `main` in sync
- Push `my-feature` to `origin`, then open a PR targeting `upstream`

One-time setup:

```bash
# Fetch from both remotes when you run `jj git fetch`
jj config set --repo git.fetch '["upstream", "origin"]'

# Default push target is your fork
jj config set --repo git.push origin

# Track both remote bookmarks named `main`
jj bookmark track main

# Make upstream's main the trunk (treated as immutable; rebases stop here)
jj config set --repo 'revset-aliases."trunk()"' main@upstream
```

Why these specifically:
- Tracking `main@upstream` keeps your local `main` updated whenever you fetch from upstream
- Tracking `main@origin` means `jj git push` will also update your fork's `main`
- `trunk() = main@upstream` prevents jj from rewriting commits that are already in the canonical repo

### Scenario 2: Independent repository, periodically integrating from upstream

`origin` is a long-lived repository with its own divergent history; `upstream` is the source you occasionally pull changes from but don't contribute back to.

Typical actions:
- Fetch from `origin` to get the latest of your own work
- Push bookmarks to `origin`; merge PRs into `main@origin`
- Periodically fetch from `main@upstream` and merge/rebase/duplicate its changes into `main@origin`

One-time setup:

```bash
# Fetch only from origin (typical case)
jj config set --repo git.fetch '["origin"]'
# Or fetch from both if you want upstream changes visible on every fetch:
#   jj config set --repo git.fetch '["upstream", "origin"]'

# Default push target is origin
jj config set --repo git.push origin

# Track only origin's main — do NOT track upstream's main
jj bookmark track main --remote=origin
jj bookmark untrack main --remote=upstream

# Your origin defines the trunk (your main is the canonical line)
jj config set --repo 'revset-aliases."trunk()"' main@origin
```

Why these specifically:
- Tracking only `main@origin` keeps `main@upstream` as a clearly separate reference you can `rebase`/`merge` from intentionally — it won't silently overwrite your local `main`
- `trunk() = main@origin` treats your divergent line (not upstream's) as the immutable history boundary

### Choosing between the scenarios

| Question | Scenario 1 | Scenario 2 |
|---|---|---|
| Do you push features back to upstream as PRs? | Yes | No |
| Should fetching from upstream update your local `main`? | Yes | No (you integrate manually) |
| Is `upstream/main` immutable from your repo's perspective? | Yes | No (you may rewrite when integrating) |
| Is `origin/main` allowed to diverge from `upstream/main`? | Minimally (just for syncing) | Yes (it's the point) |
