---
name: prime
description: 'Load Beads context at the start of a session, then summarize active, blocked, and ready work. Use when the user asks to prime, initialize, or recover project task context.'
user-invocable: true
disable-model-invocation: true
---

# Prime Project Context

Use this workflow to recover durable task context from Beads before beginning
work.

## Procedure

1. Run `bd prime` in the repository.
2. Inspect project state with `bd ready` and `bd list`.
3. Use `bd show <id>` only for beads needed to understand current priorities,
   blockers, or dependencies.
4. Summarize in a few lines what is in progress, what needs attention, and what
   work is ready next. Include bead IDs so the user can inspect the records.

If Beads is unavailable or `bd prime` fails, report that clearly and stop. Do
not initialize Beads or create workflow configuration unless the user
explicitly asks.