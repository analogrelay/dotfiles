---
name: handoff
description: 'Capture durable end-of-session state in Beads, including completed work, resume notes, follow-ups, blockers, and operational lessons. Use when the user asks to hand off, wrap up, or make the conversation disposable.'
user-invocable: true
disable-model-invocation: true
---

# Capture Session Handoff

Use this workflow to make the current conversation disposable by preserving
all durable task and project knowledge.

## Procedure

1. Run `bd prime` to load the current Beads workflow and project state.
2. Review every bead touched during the session.
3. Close completed beads with concise notes describing what changed and how it
   was verified.
4. For incomplete beads, record the exact resume state: completed work,
   remaining work, validation results, blockers, and failed approaches.
5. Create a bead for each follow-up, idea, or TODO from the conversation that
   is not already tracked. Report the beads created.
6. Use `bd remember` for concise operational lessons that should survive the
   session.
7. Run `bd ready` or inspect relevant open beads to confirm that remaining work
   and blockers are accurately represented.
8. Confirm `Beads state captured - this conversation can be discarded`. If anything
   remains only in chat, list it and explain why it could not be persisted.

If Beads is unavailable or `bd prime` fails, report that clearly and stop. Do
not initialize Beads or create workflow configuration unless the user
explicitly asks.

Do not duplicate existing beads. Preserve concrete evidence and resume details
rather than conversational summaries.