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

Files are only tended when they end in `.ready`. Writers must:

1. write to `name.incoming`
2. rename to `name.ready` once the write is complete

This avoids tending half-written files.

## Notes

- Polling interval: `POLL_INTERVAL=1`
- No network, no database, no queue, no dependencies
