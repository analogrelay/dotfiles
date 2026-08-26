# Engineering workflow

Use Beads as the source of truth for planning and tracking work. Use the
`bd` CLI for Beads operations. If the current repo is not yet initialized with Beads, report this to the user and stop immediately.

## Start every session

Run `bd prime` before investigating or changing the repository. Use its output
to recover project context, then inspect the relevant bead and nearby in-repo
documentation before starting work.

If Beads is not initialized or `bd prime` fails, report that clearly. Do not
initialize Beads, create configuration, or add workflow files unless the user
explicitly asks you to.

## Plan and claim work

1. Treat beads as the authoritative record of planned, active, blocked, and
   completed work.
2. Before implementation, identify the relevant bead with `bd ready`, `bd
   list`, or an ID supplied by the user.
3. Read the bead with `bd show <id>` and confirm that its scope and acceptance
   criteria cover the requested change.
4. Claim the bead with `bd update <id> --claim` before editing code.
5. If the requested work is not represented, create a bead with a clear
   problem statement and testable acceptance criteria, then claim it.
6. Represent meaningful ordering or blocking relationships with Beads
   dependencies so `bd ready` reflects the actual work order.

Keep each bead small enough for one focused unit of work. Split work when parts
can be implemented or verified independently.

## Implement against the bead

- Keep the change within the claimed bead's scope and acceptance criteria.
- Prefer the smallest complete implementation that resolves the bead.
- Record substantial follow-up work as new beads instead of expanding the
  current change or leaving it only in chat or code comments.
- Update the bead when new information changes its scope, dependencies, or
  status.
- If blocked, record the blocker and any dependency in Beads before moving on.

## Maintain in-repo documentation

Repository documentation is the durable explanation of how the project works.
Before changing a documented system, read the relevant `README`, `docs/`, ADR,
runbook, or nearby design document.

Update existing in-repo documentation as part of the same bead when:

- behavior, interfaces, setup, or operational procedures change;
- an architectural or product decision needs durable rationale;
- investigation reveals that current documentation is missing or incorrect;
- future contributors would otherwise need to rediscover important context.

Follow the repository's existing documentation structure and conventions. Do
not create a new documentation hierarchy when an established location already
exists. Keep task status and short-lived planning in Beads; keep stable system
knowledge and decision rationale in repository documentation.

## Verify and finish

1. Validate the implementation with the narrowest relevant tests, checks, and
   acceptance criteria, then broaden validation when the change's risk warrants
   it.
2. Update affected in-repo documentation before marking the work complete.
3. Close the bead with a concise note describing what changed and how it was
   verified.
4. Create beads for discovered follow-up work, including deferred fixes and
   documentation gaps.
5. Before ending the session, run `bd ready` or inspect relevant open beads to
   ensure the remaining work and blockers are accurately represented.

Conversations are temporary. Preserve durable task state in Beads and durable
project knowledge in the repository.