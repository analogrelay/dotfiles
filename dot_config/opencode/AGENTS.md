# Engineering protocol (global — applies in every project)

## Context bootstrap (do this before anything else)

Run:

    eval "$(tower-ctx)" && bd prime

If `tower-ctx` fails, this repo has no registered project state. Say so once,
then proceed as a normal coding session without beads/brain. Do NOT create
beads databases, brain folders, or config files inside the repo to compensate —
especially in shared repos. Suggest the user run `tower-init` if it seems useful.

If it succeeds, you have:
- `$BEADS_DIR` — the beads database (bd picks this up automatically)
- `$TOWER_BRAIN` — markdown knowledge root, with `brain/` (decisions, playbooks)
  and `doc/` (how systems work; start at `doc/INDEX.md`)
- `$TOWER_GH_REPO` — GitHub owner/repo for `gh` commands (may be empty)

- `$TOWER_ROLE` — your standing in this repo; it changes your behavior:

  | role        | meaning                        | behavioral consequences |
  |-------------|--------------------------------|-------------------------|
  | owner       | user's own project             | committing state (`.beads/`, `knowledge/`) in-repo is fine; GitHub writes still need approval |
  | maintainer  | shared repo, user has push     | ALL eng state stays out-of-band; branches may be pushed to origin when asked |
  | contributor | fork/OSS workflow              | strictest: state out-of-band; never assume push access to upstream; PRs go from the fork; treat upstream issues/discussions as read-only context |

Config comes from git config (`tower.*` keys, same mechanism beads uses for
`beads.role`). Per-clone overrides: `git config --local tower.<key> <value>`.

Note: `eval` only persists within a single bash invocation. Either chain
commands (`eval "$(tower-ctx)" && bd ...`) or re-eval per bash call.

## Ground rules

1. **Beads are the source of truth for work.** No implementation without a
   claimed bead (`bd update <id> --claim`). If asked to do unplanned work,
   create the bead first — with acceptance criteria — then claim it.
2. **The brain is the source of truth for knowledge.** Before working on a
   system, read its `doc/` file. If you learn the doc is wrong or missing,
   fixing it is part of the task.
3. **Conversations are disposable.** Anything worth keeping must land in a
   bead, `bd remember`, or the brain before the session ends. Assume the next
   session starts cold from `bd prime` + the brain.
4. **Shared repos stay clean.** Never write tower state, agent config, or
   planning files into a repo unless `tower.role` is `owner` for it (git
   config, not repo files — see the state model above). Out-of-band means
   out-of-band: no exceptions for convenience.
5. **`bd remember` is for one-paragraph operational facts** (gotchas, env
   quirks, "X breaks unless Y"). Durable design rationale goes in
   `$TOWER_BRAIN/brain/`; system explanations go in `$TOWER_BRAIN/doc/`.

## GitHub conventions (when $TOWER_GH_REPO is set)

- Beads mirroring a GitHub issue include a line `GitHub: <issue-url>` at the
  top of their description. When closing such a bead, remind the user the
  linked issue may need a comment/close — do not comment or close it yourself
  unless asked.
- Branches for a bead are named `bead/<id>-<slug>`. PR bodies include a line
  `Bead: <id>`.
- `gh` is read-freely / write-carefully: reading issues, PRs, diffs, checks is
  always fine; creating or mutating anything on GitHub requires explicit user
  approval in this session.

## Session close (before you stop)

- Close finished beads with a note on what was done and how it was verified.
- File follow-up beads for anything discovered but not done — never leave TODOs
  only in chat or code comments.
- `bd remember` any new gotchas; update `doc/` if system behavior changed.
