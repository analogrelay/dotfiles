---
description: Load project context (beads + brain) and summarize where things stand
---

Run `eval "$(tower-ctx)" && bd prime`, then `tower-brief`. Read
`$TOWER_BRAIN/doc/INDEX.md`. Summarize in a few lines: what this project is,
what's in flight, and what's ready. If tower-ctx fails, say the repo isn't
registered and continue without state.
