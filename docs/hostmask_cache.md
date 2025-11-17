# Hostmask cache & USER_HOSTMASK table

To reduce the latency of `get_user_from_message`, hostmasks are now split and
stored in the `USER_HOSTMASK` table. Each row contains a single mask, its
lowercase copy and a SQL-friendly pattern so we can either run parametrised
queries (`? LIKE mask_sql`) or rebuild the in-memory regex cache instantly.

## Populating the table

Fresh installs automatically create the table via `install/mediabot.sql`.
Existing deployments can backfill the table without downtime using:

```
contrib/tools/rebuild_hostmask_index.pl --dsn DBI:mysql:database=mediabot \
    --user mediabot --pass secret
```

You can also export DB credentials through the `MEDIABOT_DSN`,
`MEDIABOT_DB_USER` and `MEDIABOT_DB_PASS` environment variables instead of
passing CLI arguments.

The script simply walks over the `USER` table, splits the `hostmasks` column
and persists the result to `USER_HOSTMASK` (which is automatically truncated for
that user before inserts).

## Cache invalidation hooks

`Mediabot::User` exposes the `register_hostmask_change_hook` and
`sync_hostmask_index` helpers. Whenever a user's hostmasks are updated, all
registered hooks are notified. `Mediabot` registers such a hook to invalidate
its in-memory cache which means the next lookup rebuilds it with the fresh
patterns.

## Quick benchmark

A synthetic benchmark is available to compare the historical linear scan with
regex compilation versus the cached approach:

```
contrib/benchmarks/hostmask_lookup.pl
```

The script generates 1,500 fake hostmasks and 500 fake messages, then runs both
algorithms 50 times using `Benchmark::cmpthese`. The absolute numbers depend on
your hardware, but the cached variant should consistently win which confirms
that the optimisation works.
