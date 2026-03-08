# P005 Seek Pagination By Timestamp

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/queries-limit.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: pagination, keyset, timestamp, seek

## Problem

Fetch the next page using a timestamp seek anchor with deterministic tie-breaking.

## SQL

```sql
SELECT o.id, o.order_number, o.inserted_at, o.total
FROM orders AS o
WHERE o.inserted_at > TIMESTAMP '2024-01-15 00:00:00'
ORDER BY o.inserted_at ASC, o.id ASC
LIMIT 25;
```

## Selecto

```elixir
query =
  Selecto.configure(order_timeseries_domain(), :mock_connection, validate: false)
  |> Selecto.select(["id", "order_number", "inserted_at", "total"])
  |> Selecto.filter({"inserted_at", {:>, ~N[2024-01-15 00:00:00]}})
  |> Selecto.order_by({"inserted_at", :asc})
  |> Selecto.order_by({"id", :asc})
  |> Selecto.limit(25)

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.id, selecto_root.order_number, selecto_root.inserted_at, selecto_root.total
        from orders selecto_root
        where (( selecto_root.inserted_at > $1 ))
      
        order by selecto_root.inserted_at asc, selecto_root.id asc
      
        limit 25
```

**Params:** `[~N[2024-01-15 00:00:00]]`

## Expected SQL Shape

- includes keyword: `inserted_at`
- includes keyword: `>`
- includes keyword: `order by`
- includes keyword: `limit`

## Notes

- Timestamp keyset pagination scales better than large offset scans.
- Add a stable secondary key (`id`) to avoid duplicate/missing rows on equal timestamps.
