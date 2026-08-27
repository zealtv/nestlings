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

