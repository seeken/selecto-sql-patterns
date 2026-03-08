# T003 Bucket By Day Projection

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/functions-datetime.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: time-series, date-trunc, bucket

## Problem

Project each order row into a day-level bucket for downstream reporting.

## SQL

```sql
SELECT o.order_number,
       date_trunc('day', o.inserted_at) AS day_bucket,
       o.total
FROM orders AS o
ORDER BY o.inserted_at ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_timeseries_domain(), :mock_connection, validate: false)
  |> Selecto.select([
    "order_number",
    {:field, {:raw_sql, "date_trunc('day', selecto_root.inserted_at)"}, "day_bucket"},
    "total"
  ])
  |> Selecto.order_by({"inserted_at", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, date_trunc('day', selecto_root.inserted_at), selecto_root.total
        from orders selecto_root
        order by selecto_root.inserted_at asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `date_trunc('day'`
- includes keyword: `selecto_root.inserted_at`
- includes keyword: `order by`
- includes keyword: `from orders`

## Notes

- Day-bucket projections are useful as a staging step before aggregation.
- Keep bucket expressions explicit and named for downstream consumers.
