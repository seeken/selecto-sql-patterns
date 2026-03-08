# T001 Datetime Range Filter Half-Open

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/functions-datetime.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: time-series, datetime, between, ranges

## Problem

Filter order events to a reporting month window using start-inclusive/end-exclusive bounds.

## SQL

```sql
SELECT o.order_number, o.inserted_at, o.total
FROM orders AS o
WHERE o.inserted_at >= TIMESTAMP '2024-01-01 00:00:00'
  AND o.inserted_at < TIMESTAMP '2024-02-01 00:00:00'
ORDER BY o.inserted_at ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_timeseries_domain(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "inserted_at", "total"])
  |> Selecto.filter({"inserted_at", {:between, ~N[2024-01-01 00:00:00], ~N[2024-02-01 00:00:00]}})
  |> Selecto.order_by({"inserted_at", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, selecto_root.inserted_at, selecto_root.total
        from orders selecto_root
        where (( (selecto_root.inserted_at >= $1 and selecto_root.inserted_at < $2) ))
      
        order by selecto_root.inserted_at asc
```

**Params:** `[~N[2024-01-01 00:00:00], ~N[2024-02-01 00:00:00]]`

## Expected SQL Shape

- includes keyword: `>=`
- includes keyword: `<`
- includes keyword: `where`
- includes keyword: `order by`

## Notes

- Datetime `:between` compiles to half-open predicates in Selecto.
- Half-open windows prevent boundary double-counting across adjacent periods.
