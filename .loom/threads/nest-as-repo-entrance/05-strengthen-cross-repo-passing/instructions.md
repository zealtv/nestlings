# Strengthen cross-repository passing

Develop the existing “communicating between nests” convention into a dependable
way to pass content and requests between repositories.

Settle the minimum conventions needed for:

- addressing or locating a receiving nest without hidden shared state;
- transferring an item through `.landing` so receivers never see partial input;
- carrying attachments and a request together;
- distinguishing the receiver's hatch record from a reply sent back to the
  origin repository;
- avoiding name collisions and preserving a useful origin trail;
- handling repositories that are not simultaneously available on one machine.

Prefer ordinary filesystem adjacency, explicit paths, and visible symlinks.
Separate the local protocol from any later synchronization or network transport.

Done when two adjacent temporary repositories can exchange a request and reply,
with tests covering partial landing and collision behavior where mechanics were
added.

