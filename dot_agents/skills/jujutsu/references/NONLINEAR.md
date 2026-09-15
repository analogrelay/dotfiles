# Nonlinear Work

This skill supports sibling commits and unrelated work. Do not force everything onto the current stack if the work is logically independent.

**Tested with jj 0.41.0**

## When to Start a Sibling from `trunk()`

Use a fresh sibling when:

- `@` already represents one logical change and the new work is unrelated
- the user wants multiple independent lines of work
- you need to compare or merge two alternative implementations
- a quick fix appears while a feature change is already in progress

## Preferred Flow

This skill keeps the local "describe first" rule, even for sibling work:

```bash
jj st
jj new trunk()
jj desc -m "fix: handle stale workspace recovery"
# make changes
jj st
```

Use `trunk()` instead of guessing `main` or `master`. If the new work should build on the current change, use plain `jj new` instead of `jj new trunk()`.

## Child vs Sibling

Use a child (`jj new`) when:

- the new work depends on the current change
- the user wants a stacked sequence
- the current commit is intentionally being split into follow-up commits

Use a sibling from `trunk()` when:

- the work should review, land, or be abandoned independently
- you are branching off to do an unrelated fix, doc change, or experiment
- parallel agents need clearly separated lines of history

## Merge-Shaped Work

If two independently meaningful lines of work should remain visible as a merge, create an explicit merge commit:

```bash
jj new <left-change> <right-change> -m "merge: combine related lines of work"
```

Ask the user before choosing between:

- rebasing one line onto the other
- keeping a visible merge
- pushing each line separately

## Anti-Patterns

- Do not keep piling unrelated work into the current `@` just because it is convenient.
- Do not adopt a `describe -> code -> jj new -> repeat` loop. In this skill, `jj new` starts the next change; it does not close the current one.
- Do not default to `jj new trunk() --no-edit -m ...` here. Keep the local sequence: choose the base first, then run `jj desc -m ...`.
- Do not hardcode `main` or `master` when `trunk()` expresses the intent.

See `references/NEW_CHANGE.md` for the default change-starting workflow and `references/WORKSPACES.md` for multi-workspace parallelism.
