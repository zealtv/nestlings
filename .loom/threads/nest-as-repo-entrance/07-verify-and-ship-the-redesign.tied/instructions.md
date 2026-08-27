# Verify and ship the redesign

Review the complete redesign as one protocol rather than a collection of doc
additions.

Verify:

- the existing lifecycle and recovery tests still pass;
- installer behavior remains idempotent and preserves host-customized `tend.md`;
- a fresh repository can start with only a nest;
- deferred batch items remain visible and claimable;
- optional composition does not introduce runtime dependencies;
- two repositories can perform the documented handoff without partial reads;
- README, installed README, examples, and command help agree.

Remove speculative machinery that the worked examples do not need. Leave a
short design record in this stitch describing the final boundary and any
follow-up deliberately deferred.

Done when the repository is releasable as the redesigned layer-zero Nestlings
protocol.

## Final design record

The shipped boundary is a local filesystem transport: Nestlings atomically
ingests, claims, completes, drops, retries, and sweeps files or directory
envelopes. Pending items may wait for a later batch. Meaning, routing, durable
memory, work planning, recurrence, synchronization, and agent behavior remain
owned by the host and any tools it explicitly selects.

Repository bootstrap and adjacent-repository handoff need no machinery beyond
the existing trays, suffix states, ordinary Markdown, and explicit paths. Typed
composition references remain an optional prose convention; the runtime does
not parse them or depend on sibling primitives. No registry, graph schema,
network transport, scheduler, or automatic sibling-tool installer is added.

Deferred follow-up: extract a family-wide composition specification only after
multiple primitive owners require shared reference resolution. A remote
transport may later deliver finished envelopes, but it must keep synchronization
outside Nestlings and preserve the atomic local `ingest` boundary.
