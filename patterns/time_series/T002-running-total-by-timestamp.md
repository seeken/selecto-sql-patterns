# T002 Running Total By Timestamp

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/tutorial-window.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: time-series, window, running-total

## Problem

Compute a cumulative order total in timestamp order.

## SQL

```sql
SELECT o.order_number,
       o.inserted_at,
       o.total,
       SUM(o.total) OVER (ORDER BY o.inserted_at) AS running_total
FROM orders AS o
ORDER BY o.inserted_at ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_timeseries_domain(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "inserted_at", "total"])
  |> Selecto.window_function(:sum, ["total"],
    over: [order_by: ["inserted_at"]],
    as: "running_total"
  )
  |> Selecto.order_by({"inserted_at", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, selecto_root.inserted_at, selecto_root.total, SUM(selecto_root.total) OVER (ORDER BY selecto_root.inserted_at ASC) AS running_total
        from orders selecto_root
        order by selecto_root.inserted_at asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `sum`
- includes keyword: `over`
- includes keyword: `order by`
- includes keyword: `running_total`

## Notes

- Window functions keep row-level detail while adding cumulative metrics.
- This shape is common in ledger and event-stream reporting.
