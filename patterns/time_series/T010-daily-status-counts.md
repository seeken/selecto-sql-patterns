# T010 Daily Status Counts

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/functions-datetime.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: time-series, date-bucket, status-counts

## Problem

Count how many orders reached each status per day.

## SQL

```sql
SELECT date_trunc('day', o.inserted_at) AS day_bucket,
       o.status,
       COUNT(*) AS order_count
FROM orders AS o
GROUP BY date_trunc('day', o.inserted_at), o.status
ORDER BY date_trunc('day', o.inserted_at) ASC, o.status ASC;
```

## Selecto

```elixir
day_bucket = "date_trunc('day', selecto_root.inserted_at)"

query =
  Selecto.configure(order_timeseries_domain(), :mock_connection, validate: false)
  |> Selecto.select([
    {:field, {:raw_sql, day_bucket}, "day_bucket"},
    "status",
    {:count, "*"}
  ])
  |> Selecto.group_by([{:raw_sql, day_bucket}, "status"])
  |> Selecto.order_by([{{:raw_sql, day_bucket}, :asc}, {"status", :asc}])

{sql, params} = Selecto.to_sql(query)
```

## Selecto Expr

```elixir
import Selecto.Expr

day_bucket = "date_trunc('day', selecto_root.inserted_at)"

Selecto.configure(order_timeseries_domain(), :mock_connection, validate: false)
|> Selecto.select([as({:raw_sql, day_bucket}, "day_bucket"), "status", count: "*"])
|> Selecto.group_by([{:raw_sql, day_bucket}, "status"])
|> Selecto.order_by([{{:raw_sql, day_bucket}, :asc}, asc("status")])
```

## Selecto Yielded SQL

```sql
select date_trunc('day', selecto_root.inserted_at), selecto_root.status, count(*)
        from orders selecto_root
        group by date_trunc('day', selecto_root.inserted_at), selecto_root.status

        order by date_trunc('day', selecto_root.inserted_at) asc, selecto_root.status asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `date_trunc('day'`
- includes keyword: `status`
- includes keyword: `count`
- includes keyword: `group by`

## Notes

- Group by both the bucket expression and the categorical status dimension.
