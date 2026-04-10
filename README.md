# 🪺 nestlings

A nestling tends its nest.

A nestling is an agent responsible for a folder — a script, an AI, or a human. This repo *is* a nest.

## The nest

```
inbox/    files waiting to be tended
done/     files the nestling has tended
failed/   files the nestling could not tend
log/      a plain text record of what happened
```

## Run the nestling

```bash
./nestling.sh
```

It watches `inbox/`, tends each `*.ready` file, and places the result in `done/`.

## Feed the nest

In another terminal:

```bash
./feed.sh "hello"
```

The tended file appears in `done/sample.txt`.

## Safe writes

A file in the inbox is hatching while it is being written. Writers must:

1. write to `name.hatching`
2. rename to `name` once the write is complete

The nestling skips anything still ending in `.hatching`, so half-written files are never tended.

## Notes

- Polling interval: `POLL_INTERVAL=1`
- No network, no database, no queue, no dependencies
