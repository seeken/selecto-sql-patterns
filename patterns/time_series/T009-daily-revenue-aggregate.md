# T009 Daily Revenue Aggregate

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/functions-datetime.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: time-series, date-bucket, aggregate

## Problem

Roll order events up to a daily grain with total revenue and order count.

## SQL

```sql
SELECT date_trunc('day', o.inserted_at) AS day_bucket,
       SUM(o.total) AS daily_total,
       COUNT(*) AS order_count
FROM orders AS o
GROUP BY date_trunc('day', o.inserted_at)
ORDER BY date_trunc('day', o.inserted_at) ASC;
```

## Selecto

```elixir
day_bucket = "date_trunc('day', selecto_root.inserted_at)"

query =
  Selecto.configure(order_timeseries_domain(), :mock_connection, validate: false)
  |> Selecto.select([
    {:field, {:raw_sql, day_bucket}, "day_bucket"},
    {:field, {:func, "SUM", ["total"]}, "daily_total"},
    {:count, "*"}
  ])
  |> Selecto.group_by([{:raw_sql, day_bucket}])
  |> Selecto.order_by({{:raw_sql, day_bucket}, :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Expr

```elixir
import Selecto.Expr

day_bucket = "date_trunc('day', selecto_root.inserted_at)"

Selecto.configure(order_timeseries_domain(), :mock_connection, validate: false)
|> Selecto.select([
  as({:raw_sql, day_bucket}, "day_bucket"),
  as(
    {:func, "SUM", ["total"]},
    "daily_total"
  ),
  count: "*"
])
|> Selecto.group_by(raw_sql: day_bucket)
|> Selecto.order_by({{:raw_sql, day_bucket}, :asc})
```

## Selecto Yielded SQL

```sql
select date_trunc('day', selecto_root.inserted_at), SUM(selecto_root.total), count(*)
        from orders selecto_root
        group by date_trunc('day', selecto_root.inserted_at)

        order by date_trunc('day', selecto_root.inserted_at) asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `date_trunc('day'`
- includes keyword: `sum`
- includes keyword: `group by`
- includes keyword: `order by`

## Notes

- Use a raw SQL bucket expression when the adapter-specific date bucketing
  function is the clearest representation.
