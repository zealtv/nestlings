# Make the nest the entrance to a repository

Redesign Nestlings as the layer-zero file primitive: a new repository can begin
with only a nest, accept material before its eventual role is known, and add
other primitives only when tending reveals a need for them.

The redesign must preserve Nestlings' small boundary. Core mechanics move items
safely through `in/`, `out/`, and `dropped/`; they must not acquire knowledge of
Loom, Lore, Glean, Groundhog, Git, or a particular agent runtime. Composition
belongs in host-local policy, examples, and optional tooling.

The resulting protocol should support:

- capture now and batch-process later;
- an item carrying both material and a note describing what should happen;
- routing an item into durable evidence, current memory, shaped work, recurrence,
  another repository, or no further action;
- bootstrapping a fresh repository from a nest without choosing its eventual
  project furniture in advance;
- keeping agent-specific instruction files minimal.

Tie this goal only after the child stitches have produced a coherent documented
workflow, exercised it against a fresh repository, and updated tests where the
protocol or installer behavior changed.

