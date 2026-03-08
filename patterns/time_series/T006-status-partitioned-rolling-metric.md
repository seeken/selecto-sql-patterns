# T006 Status-Partitioned Rolling Metric

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/tutorial-window.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: time-series, windows, partitioned-metrics

## Problem

Compute a running total per status over event time.

## SQL

```sql
SELECT o.order_number,
       o.status,
       o.inserted_at,
       o.total,
       SUM(o.total) OVER (
         PARTITION BY o.status
         ORDER BY o.inserted_at
       ) AS status_running_total
FROM orders AS o
ORDER BY o.inserted_at ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_timeseries_domain(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "status", "inserted_at", "total"])
  |> Selecto.window_function(:sum, ["total"],
    over: [partition_by: ["status"], order_by: ["inserted_at"]],
    as: "status_running_total"
  )
  |> Selecto.order_by({"inserted_at", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.inserted_at, selecto_root.total, SUM(selecto_root.total) OVER (PARTITION BY selecto_root.status ORDER BY selecto_root.inserted_at ASC) AS status_running_total
        from orders selecto_root
        order by selecto_root.inserted_at asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `sum`
- includes keyword: `partition by`
- includes keyword: `order by`
- includes keyword: `status_running_total`

## Notes

- Partitioned rolling metrics expose trajectory by workflow state.
- This is useful for per-status throughput monitoring.
