# T007 Keyset Pagination Over Timestamp

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/queries-limit.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: time-series, pagination, keyset

## Problem

Continue a descending time-series feed using a timestamp plus id cursor.

## SQL

```sql
SELECT o.id, o.order_number, o.inserted_at, o.total
FROM orders AS o
WHERE o.inserted_at < TIMESTAMP '2024-02-01 00:00:00'
   OR (o.inserted_at = TIMESTAMP '2024-02-01 00:00:00' AND o.id < 2000)
ORDER BY o.inserted_at DESC, o.id DESC
LIMIT 25;
```

## Selecto

```elixir
query =
  Selecto.configure(order_timeseries_domain(), :mock_connection, validate: false)
  |> Selecto.select(["id", "order_number", "inserted_at", "total"])
  |> Selecto.filter(
    {:or,
     [
       {"inserted_at", {:<, ~N[2024-02-01 00:00:00]}},
       {:and,
        [
          {"inserted_at", ~N[2024-02-01 00:00:00]},
          {"id", {:<, 2000}}
        ]}
     ]}
  )
  |> Selecto.order_by({"inserted_at", :desc})
  |> Selecto.order_by({"id", :desc})
  |> Selecto.limit(25)

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.id, selecto_root.order_number, selecto_root.inserted_at, selecto_root.total
        from orders selecto_root
        where (((( selecto_root.inserted_at < $1 ) or ((( selecto_root.inserted_at = $2 ) and ( selecto_root.id < $3 ))))))
      
        order by selecto_root.inserted_at desc, selecto_root.id desc
      
        limit 25
```

**Params:** `[~N[2024-02-01 00:00:00], ~N[2024-02-01 00:00:00], 2000]`

## Expected SQL Shape

- includes keyword: `where`
- includes keyword: ` or `
- includes keyword: `order by`
- includes keyword: `limit`

## Notes

- Composite cursor predicates avoid duplicates across page boundaries.
- Timestamp feeds should always include a stable tie-breaker key.
