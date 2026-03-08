# T004 Trailing Window Average

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/tutorial-window.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: time-series, window, trailing-average

## Problem

Compute a trailing 3-row average over ordered order events.

## SQL

```sql
SELECT o.order_number,
       o.inserted_at,
       o.total,
       AVG(o.total) OVER (
         ORDER BY o.inserted_at
         ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ) AS trailing_avg_total
FROM orders AS o
ORDER BY o.inserted_at ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_timeseries_domain(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "inserted_at", "total"])
  |> Selecto.window_function(:avg, ["total"],
    over: [
      order_by: ["inserted_at"],
      frame: {:rows, {:preceding, 2}, :current_row}
    ],
    as: "trailing_avg_total"
  )
  |> Selecto.order_by({"inserted_at", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, selecto_root.inserted_at, selecto_root.total, AVG(selecto_root.total) OVER (ORDER BY selecto_root.inserted_at ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS trailing_avg_total
        from orders selecto_root
        order by selecto_root.inserted_at asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `avg`
- includes keyword: `over`
- includes keyword: `preceding`
- includes keyword: `trailing_avg_total`

## Notes

- A row-based trailing frame gives a stable moving average window.
- This is useful for smoothing noisy time-series metrics.
