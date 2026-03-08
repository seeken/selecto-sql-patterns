# T005 Period-Over-Period Lag

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/tutorial-window.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: time-series, lag, period-over-period

## Problem

Show each order total alongside the previous period total for change analysis.

## SQL

```sql
SELECT o.order_number,
       o.inserted_at,
       o.total,
       LAG(o.total, 1) OVER (ORDER BY o.inserted_at) AS previous_total
FROM orders AS o
ORDER BY o.inserted_at ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_timeseries_domain(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "inserted_at", "total"])
  |> Selecto.window_function(:lag, ["total", 1],
    over: [order_by: ["inserted_at"]],
    as: "previous_total"
  )
  |> Selecto.order_by({"inserted_at", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, selecto_root.inserted_at, selecto_root.total, LAG(selecto_root.total) OVER (ORDER BY selecto_root.inserted_at ASC) AS previous_total
        from orders selecto_root
        order by selecto_root.inserted_at asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `lag(`
- includes keyword: `over`
- includes keyword: `previous_total`
- includes keyword: `order by`

## Notes

- `LAG` is useful for period-over-period deltas and trend calculations.
- Keep ordering explicit to define period progression.
